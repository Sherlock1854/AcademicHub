// functions/index.js

const admin = require("firebase-admin");
const { setGlobalOptions } = require("firebase-functions");
const { onCall } = require("firebase-functions/v2/https");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");

admin.initializeApp();

// limit concurrency / set region if you like
setGlobalOptions({
  maxInstances: 10,
  region: "us-central1",
});

// 1) Callable manual push
exports.sendPushNotification = onCall(async (req) => {
  const { targetUserId, title, body } = req.data ?? {};
  if (!targetUserId || !title || !body) {
    throw new Error("targetUserId, title and body are required");
  }

  const userSnap = await admin.firestore().collection("Users").doc(targetUserId).get();
  const token = userSnap.exists ? userSnap.data().fcmToken : null;
  if (!token) throw new Error("No FCM token for targetUserId");

  await admin.messaging().send({
    token,
    notification: { title, body },
  });
  return { success: true };
});

// 2) New comment → notify post author
exports.notifyOnComment = onDocumentCreated(
  "topics/{topicId}/posts/{postId}/comments/{commentId}",
  async (snap, ctx) => {
    const comment = snap.data();
    const { topicId, postId } = ctx.params;

    // load the post
    const postSnap = await admin
      .firestore()
      .collection("topics")
      .doc(topicId)
      .collection("posts")
      .doc(postId)
      .get();
    if (!postSnap.exists) return;

    const post = postSnap.data();
    const authorId = post.author;
    if (!authorId || authorId === comment.authorId) return;

    const userSnap = await admin.firestore().collection("Users").doc(authorId).get();
    const token = userSnap.exists ? userSnap.data().fcmToken : null;
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title: "New comment on your post",
        body: comment.text?.slice(0, 100) + (comment.text?.length > 100 ? "…" : ""),
      },
      data: { topicId, postId, type: "comment" },
    });
  }
);

// 3) Post updated → if likeCount increased, notify author
exports.notifyOnLike = onDocumentUpdated(
  "topics/{topicId}/posts/{postId}",
  async (change, ctx) => {
    const before = change.before.data() || {};
    const after = change.after.data() || {};
    const prevLikes = before.likeCount ?? 0;
    const newLikes = after.likeCount ?? 0;
    if (newLikes <= prevLikes) return;

    const authorId = after.author;
    if (!authorId) return;

    const userSnap = await admin.firestore().collection("Users").doc(authorId).get();
    const token = userSnap.exists ? userSnap.data().fcmToken : null;
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title: "Someone liked your post",
        body: `Your post now has ${newLikes} like${newLikes > 1 ? "s" : ""}.`,
      },
      data: { topicId: ctx.params.topicId, postId: ctx.params.postId, type: "like" },
    });
  }
);
