import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/comment_model.dart';

class JokeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Joke streams ──────────────────────────────────────────────────

  /// All jokes, newest first.
  Stream<List<Joke>> get jokesStream {
    return _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Top 10 jokes by likes.
  Stream<List<Joke>> get bestJokesStream {
    return _db
        .collection('jokes')
        .orderBy('likesCount', descending: true)
        .limit(10)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Daily joke from config/dailyJoke.
  ///
  /// Priority:
  ///   1. Admin-set joke in `config/dailyJoke { jokeId }`.
  ///   2. Deterministic fallback: same joke all day, rotates at midnight.
  ///      Seed = today's date integer (e.g. 20260701) → no randomness.
  Stream<Joke?> get dailyJokeStream {
    return _db
        .collection('config')
        .doc('dailyJoke')
        .snapshots()
        .asyncMap((configSnap) async {
      // 1. Admin-configured joke
      if (configSnap.exists) {
        final jokeId = configSnap.data()?['jokeId'] as String?;
        if (jokeId != null && jokeId.isNotEmpty) {
          final jokeDoc = await _db.collection('jokes').doc(jokeId).get();
          if (jokeDoc.exists) return Joke.fromFirestore(jokeDoc);
        }
      }
      // 2. Deterministic daily fallback
      return _getDailyFallbackJoke();
    });
  }

  /// Returns the same joke for the entire calendar day.
  /// Uses `yyyyMMdd` as an integer seed → reproducible, no shuffle.
  Future<Joke?> _getDailyFallbackJoke() async {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;

    final snapshot = await _db
        .collection('jokes')
        .orderBy('createdAt')
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Joke.fromFirestore(snapshot.docs[daySeed % snapshot.docs.length]);
  }

  /// Jokes filtered by [category] (canonical Firestore key), newest first.
  Stream<List<Joke>> getJokesByCategory(String category) {
    return _db
        .collection('jokes')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Jokes liked by [userId] (favorites), newest first.
  Stream<List<Joke>> getFavoriteJokes(String userId) {
    return _db
        .collection('jokes')
        .where('likedBy', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Jokes posted by [userId], newest first.
  Stream<List<Joke>> getUserJokes(String userId) {
    return _db
        .collection('jokes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  // ── Joke CRUD ───────────────────────────────────────────────────

  Future<void> addJoke(Joke joke) async {
    await _db.collection('jokes').add(joke.toMap());
  }

  Future<void> deleteJoke(String jokeId) async {
    await _db.collection('jokes').doc(jokeId).delete();
  }

  // ── Interactions ────────────────────────────────────────────────

  /// Toggles like/unlike for [userId] on [jokeId] — atomic transaction.
  Future<void> likeJoke(String jokeId, String userId) async {
    final jokeRef = _db.collection('jokes').doc(jokeId);
    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(jokeRef);
      if (!snapshot.exists) return;

      final likedBy =
          List<String>.from(snapshot.get('likedBy') as List? ?? []);
      int likesCount = snapshot.get('likesCount') as int? ?? 0;

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

  /// Adds a comment and increments commentsCount atomically via WriteBatch.
  Future<void> addComment(Comment comment) async {
    final batch = _db.batch();
    final commentRef = _db.collection('comments').doc();
    final jokeRef = _db.collection('jokes').doc(comment.jokeId);

    batch.set(commentRef, comment.toMap());
    batch.update(jokeRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();
  }

  /// Real-time stream of comments for [jokeId], newest first.
  /// Requires composite index: comments(jokeId ASC, createdAt DESC).
  Stream<List<Comment>> getCommentsStream(String jokeId) {
    return _db
        .collection('comments')
        .where('jokeId', isEqualTo: jokeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(Comment.fromFirestore).toList());
  }

  // ── User stats ─────────────────────────────────────────────────

  /// Returns {jokesCount, totalLikes, totalComments} for [userId].
  Future<Map<String, int>> getUserStats(String userId) async {
    final snapshot = await _db
        .collection('jokes')
        .where('authorId', isEqualTo: userId)
        .get();

    int jokesCount = snapshot.docs.length;
    int totalLikes = 0;
    int totalComments = 0;

    for (final doc in snapshot.docs) {
      totalLikes += doc.data()['likesCount'] as int? ?? 0;
      totalComments += doc.data()['commentsCount'] as int? ?? 0;
    }

    return {
      'jokesCount': jokesCount,
      'totalLikes': totalLikes,
      'totalComments': totalComments,
    };
  }

  // ── Search ───────────────────────────────────────────────────────────────

  /// Returns jokes whose content/punchline/author contains [query] (case-insensitive).
  Future<List<Joke>> searchJokes(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.trim().toLowerCase();
    final snapshot = await _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map(Joke.fromFirestore)
        .where((j) =>
            j.contentFr.toLowerCase().contains(lower) ||
            (j.contentEn?.toLowerCase().contains(lower) ?? false) ||
            (j.punchlineFr?.toLowerCase().contains(lower) ?? false) ||
            (j.punchlineEn?.toLowerCase().contains(lower) ?? false) ||
            j.authorName.toLowerCase().contains(lower))
        .toList();
  }
}
