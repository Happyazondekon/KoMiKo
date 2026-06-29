import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komiko/models/joke_model.dart';

import 'package:komiko/models/comment_model.dart';

class JokeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get stream of jokes
  Stream<List<Joke>> get jokesStream {
    return _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Joke.fromFirestore(doc)).toList());
  }

  // Get best jokes of the day
  Stream<List<Joke>> get bestJokesStream {
    return _db
        .collection('jokes')
        .orderBy('likesCount', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Joke.fromFirestore(doc)).toList());
  }

  // Add a new joke
  Future<void> addJoke(Joke joke) async {
    await _db.collection('jokes').add(joke.toMap());
  }

  // Like a joke
  Future<void> likeJoke(String jokeId, String userId) async {
    DocumentReference jokeRef = _db.collection('jokes').doc(jokeId);
    return _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(jokeRef);
      if (!snapshot.exists) return;

      List<String> likedBy = List<String>.from(snapshot.get('likedBy') ?? []);
      int likesCount = snapshot.get('likesCount') ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        likesCount -= 1;
      } else {
        likedBy.add(userId);
        likesCount += 1;
      }

      transaction.update(jokeRef, {
        'likedBy': likedBy,
        'likesCount': likesCount,
      });
    });
  }

  // Add a comment
  Future<void> addComment(Comment comment) async {
    await _db.collection('comments').add(comment.toMap());
    // Increment comments count on joke
    await _db.collection('jokes').doc(comment.jokeId).update({
      'commentsCount': FieldValue.increment(1),
    });
  }

  // Get comments for a joke
  Stream<List<Comment>> getCommentsStream(String jokeId) {
    return _db
        .collection('comments')
        .where('jokeId', isEqualTo: jokeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList());
  }
}
