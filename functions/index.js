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
  const { targetUserId, title, body } = req.data || {};
  if (!targetUserId || !title || !body) {
    throw new Error("targetUserId, title and body are required");
  }

  // lookup FCM token
  const userSnap = await admin.firestore().collection("Users").doc(targetUserId).get();
  const token = userSnap.exists ? userSnap.data().fcmToken : null;
  if (!token) throw new Error("No FCM token for targetUserId");

  // send both notification *and* data
  await admin.messaging().send({
    token,
    notification: { title, body },
    data: {
      // this key must match what your app-side onMessage is expecting:
      'friendId': targetUserId
    },
    android: {
      notification: {
        sound: "default",
        priority: "high",
      }
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        }
      }
    }
  });

  return { success: true };
});

// 2) New comment → notify post author
exports.notifyOnComment = onDocumentCreated(
  "topics/{topicId}/posts/{postId}/comments/{commentId}",
  async (event) => {
    // event.data is the DocumentSnapshot-like object
    const comment = event.data;
    const { topicId, postId } = event.params;

    // rest is identical
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

    const textSnippet =
      (comment.text || "").slice(0, 100) +
      ((comment.text || "").length > 100 ? "…" : "");

    const userSnap = await admin
      .firestore()
      .collection("Users")
      .doc(authorId)
      .get();
    const token = userSnap.exists ? userSnap.data().fcmToken : null;
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title: "New comment on your post",
        body: textSnippet,
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

    const body = `Your post now has ${newLikes} like${newLikes > 1 ? "s" : ""}.`;
    const userSnap = await admin.firestore().collection("Users").doc(authorId).get();
    const token = userSnap.exists && userSnap.data().fcmToken;
    if (!token) return;

    await admin.messaging().send({
      token,
      notification: {
        title: "Someone liked your post",
        body,
      },
      data: {
        topicId: ctx.params.topicId,
        postId: ctx.params.postId,
        type: "like",
      },
    });
  }
);

////////////////////////////////////////////////////////////////////////////////
// 4) New friend request → notify target user
////////////////////////////////////////////////////////////////////////////////
exports.notifyOnFriendRequest = onDocumentCreated(
  "Users/{toUid}/receivedRequests/{requesterUid}",
  async (snap, ctx) => {
    // 1️⃣ pull the new request doc data + path params
    const reqData = snap.data() || {};
    const { toUid, requesterUid } = ctx.params;

    // 2️⃣ sanity check
    if (!toUid || !requesterUid || toUid === requesterUid) return;

    // 3️⃣ grab sender’s display name
    const senderName = typeof reqData.name === "string"
      ? reqData.name
      : "Someone";

    // 4️⃣ lookup recipient’s FCM token
    const userSnap = await admin.firestore()
      .collection("Users")
      .doc(toUid)
      .get();
    const token = userSnap.exists ? userSnap.data().fcmToken : null;
    if (!token) return;

    // 5️⃣ fire the push exactly like notifyOnLike
    await admin.messaging().send({
      token,
      notification: {
        title: senderName,
        body:  "sent you a friend request",
      },
      data: {
        friendId: requesterUid,
        type:     "friend_request",
      },
    });
  }
);