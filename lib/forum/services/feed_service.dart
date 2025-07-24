// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/feed_post.dart';
//
// class FeedService {
//   final _db = FirebaseFirestore.instance;
//
//   /// Stream of feed posts
//   Stream<List<FeedPost>> feed() {
//     return _db
//         .collection('feed_posts')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map((d) => FeedPost.fromDoc(d)).toList());
//   }
// }
