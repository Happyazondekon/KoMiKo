import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/models/comment_model.dart';
import 'package:komiko/services/content_moderation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JokeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _moderation = ContentModerationService.instance;

  // ── Feed intelligent (style Facebook/Instagram/X + IA Groq) ──────────────────────────

  /// Calcule le score de pertinence d'une blague pour le feed.
  ///
  /// Score = (likesCount × 3) + (commentsCount × 2) + RecenceBonus
  ///         + FeaturedBonus + VerifiedAuthorBonus + OwnPostBonus + CategoryAffinityBonus
  ///
  /// - RecenceBonus : max(0, 100 - heures_depuis_publication × 2)
  /// - FeaturedBonus : +500 si la blague est mise en vedette
  /// - VerifiedAuthorBonus : +250 pour valoriser les créateurs vérifiés & Pro
  /// - OwnPostBonus : +3000 si c'est le dernier post de l'utilisateur connecté (apparaît en premier)
  /// - CategoryAffinityBonus : +350 si la catégorie correspond aux goûts habituels de l'utilisateur
  double _computeScore(
    Joke joke, {
    String? currentUserId,
    String? lastOwnPostId,
    Set<String>? favoriteCategories,
  }) {
    final hoursSincePost = DateTime.now().difference(joke.createdAt).inHours;
    final recenceBonus = (100 - hoursSincePost * 2).clamp(0, 100).toDouble();
    final featuredBonus = joke.isFeatured ? 500.0 : 0.0;
    final verifiedBonus = joke.isAuthorVerified ? 250.0 : 0.0;
    final ownPostBonus = (lastOwnPostId != null && joke.id == lastOwnPostId) ? 3000.0 : 0.0;
    final categoryAffinityBonus =
        (favoriteCategories != null && favoriteCategories.contains(joke.category))
            ? 350.0
            : 0.0;

    return (joke.likesCount * 3) +
        (joke.commentsCount * 2) +
        recenceBonus +
        featuredBonus +
        verifiedBonus +
        ownPostBonus +
        categoryAffinityBonus;
  }

  /// Feed principal — retourne les blagues triées par score Komiko et affinité IA.
  ///
  /// - Récupère les 200 dernières blagues
  /// - Déduit les catégories préférées de l'utilisateur d'après ses likes
  /// - Filtre les blagues masquées par l'admin
  /// - Met en avant les posts des créateurs vérifiés et Pro
  /// - Le dernier post de l'utilisateur connecté apparaît toujours en premier
  Stream<List<Joke>> feedStream({String? currentUserId}) {
    return _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .asyncMap((snapshot) async {
      String? lastOwnPostId;
      Set<String> favoriteCategories = {};

      if (currentUserId != null && currentUserId.isNotEmpty) {
        // 1. Trouver le dernier post de l'utilisateur
        final ownJokes = snapshot.docs
            .where((d) => (d.data()['authorId'] as String?) == currentUserId)
            .toList();
        if (ownJokes.isNotEmpty) {
          lastOwnPostId = ownJokes.first.id;
        }

        // 2. Déduire les préférences d'humour de l'utilisateur d'après ses blagues likées
        final userLikedJokes = snapshot.docs.where((d) {
          final likedBy = List<String>.from(d.data()['likedBy'] as List? ?? []);
          return likedBy.contains(currentUserId);
        });
        for (final doc in userLikedJokes) {
          final cat = doc.data()['category'] as String?;
          if (cat != null && cat.isNotEmpty) {
            favoriteCategories.add(cat);
          }
        }
      }

      final locallyHidden = await getLocallyHiddenJokeIds();
      final jokes = snapshot.docs
          .map(Joke.fromFirestore)
          .where((j) => !j.isHidden && !locallyHidden.contains(j.id))
          .toList();

      // Trier par score décroissant en appliquant l'affinité personnalisée
      jokes.sort((a, b) {
        final scoreA = _computeScore(
          a,
          currentUserId: currentUserId,
          lastOwnPostId: lastOwnPostId,
          favoriteCategories: favoriteCategories,
        );
        final scoreB = _computeScore(
          b,
          currentUserId: currentUserId,
          lastOwnPostId: lastOwnPostId,
          favoriteCategories: favoriteCategories,
        );
        return scoreB.compareTo(scoreA);
      });

      return jokes;
    });
  }

  // ── Joke streams ──────────────────────────────────────────────────

  /// All jokes, limited to the latest 50 for performance.
  Stream<List<Joke>> get jokesStream {
    return _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .limit(50)
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

  /// Returns a unique joke for each day of the year based on a linear sequence.
  /// With 1216 jokes, this covers over 3 years without repetition.
  Future<Joke?> _getDailyFallbackJoke() async {
    final now = DateTime.now();
    
    // We use the number of days since a fixed epoch (e.g., Jan 1, 2024) 
    // to ensure a continuous sequence that doesn't just repeat every 365 days 
    // if the collection is larger than 365.
    final epoch = DateTime(2024, 1, 1);
    final daysSinceEpoch = now.difference(epoch).inDays;

    final snapshot = await _db
        .collection('jokes')
        .orderBy('createdAt', descending: false)
        .limit(2000) // Fetch the pool of jokes to choose from
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    // Map the current day to a specific joke in the collection
    final jokeIndex = daysSinceEpoch % snapshot.docs.length;
    
    return Joke.fromFirestore(snapshot.docs[jokeIndex]);
  }

  /// Jokes filtered by [category] (canonical Firestore key), newest first.
  Stream<List<Joke>> getJokesByCategory(String category) {
    return _db
        .collection('jokes')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Jokes liked by [userId] (favorites), newest first.
  Stream<List<Joke>> getFavoriteJokes(String userId) {
    return _db
        .collection('jokes')
        .where('likedBy', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Jokes posted by [userId], newest first.
  Stream<List<Joke>> getUserJokes(String userId) {
    return _db
        .collection('jokes')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Fetches a single joke by ID as a real-time stream.
  Stream<Joke?> getJokeStream(String jokeId) {
    return _db
        .collection('jokes')
        .doc(jokeId)
        .snapshots()
        .map((s) => s.exists ? Joke.fromFirestore(s) : null);
  }

  // ── Joke CRUD ───────────────────────────────────────────────────

  /// Ajoute une blague avec censure automatique du contenu.
  Future<void> addJoke(Joke joke) async {
    // Appliquer la censure sur le contenu avant publication
    final censoredJoke = joke.copyWith(
      contentFr: _moderation.censorText(joke.contentFr),
      punchlineFr: joke.punchlineFr != null
          ? _moderation.censorText(joke.punchlineFr!)
          : null,
      contentEn: joke.contentEn != null
          ? _moderation.censorText(joke.contentEn!)
          : null,
      punchlineEn: joke.punchlineEn != null
          ? _moderation.censorText(joke.punchlineEn!)
          : null,
    );
    await _db.collection('jokes').add(censoredJoke.toMap());
  }

  Future<void> deleteJoke(String jokeId) async {
    await _db.collection('jokes').doc(jokeId).delete();
  }

  // ── Actions admin ──────────────────────────────────────────────

  /// Met en vedette / retire une blague (admin uniquement).
  Future<void> setFeatured(String jokeId, bool featured) async {
    await _db.collection('jokes').doc(jokeId).update({'isFeatured': featured});
  }

  /// Cache / affiche une blague (admin uniquement).
  Future<void> setHidden(String jokeId, bool hidden) async {
    await _db.collection('jokes').doc(jokeId).update({'isHidden': hidden});
  }

  // ── Signalement & Masquage local ──────────────────────────────────────────

  static const String _hiddenJokesKey = 'komiko_hidden_joke_ids';

  /// Mémorise localement qu'une blague doit être masquée du feed de l'utilisateur.
  static Future<void> hideJokeLocally(String jokeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_hiddenJokesKey) ?? [];
      if (!list.contains(jokeId)) {
        list.add(jokeId);
        await prefs.setStringList(_hiddenJokesKey, list);
      }
    } catch (_) {}
  }

  /// Récupère la liste des blagues masquées localement par l'utilisateur.
  static Future<List<String>> getLocallyHiddenJokeIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_hiddenJokesKey) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Signale une blague avec motif et commentaire optionnel, et la masque du feed.
  Future<void> reportJoke({
    required String jokeId,
    required String userId,
    required String reason,
    String? comment,
  }) async {
    // 1. Incrémenter reportCount sur la blague
    try {
      await _db
          .collection('jokes')
          .doc(jokeId)
          .update({'reportCount': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error updating joke reportCount: $e');
    }

    // 2. Enregistrer le détail du signalement pour l'admin
    try {
      await _db.collection('reports').add({
        'jokeId': jokeId,
        'reporterId': userId,
        'reason': reason,
        'comment': comment?.trim() ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving report detail: $e');
    }

    // 3. Masquer localement du feed
    await hideJokeLocally(jokeId);
  }

  /// Récupère les blagues signalées (reportCount > 0), triées par signalements.
  Stream<List<Joke>> get reportedJokesStream {
    return _db
        .collection('jokes')
        .where('reportCount', isGreaterThan: 0)
        .orderBy('reportCount', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(Joke.fromFirestore).toList());
  }

  /// Récupère les blagues avec photo.
  Stream<List<Joke>> get jokesWithImageStream {
    return _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs
            .map(Joke.fromFirestore)
            .where((j) => j.imageBase64 != null && j.imageBase64!.isNotEmpty)
            .toList());
  }

  // ── Interactions ────────────────────────────────────────────────

  /// Toggles like/unlike for [userId] on [jokeId] — atomic transaction.
  Future<void> likeJoke(String jokeId, String userId) async {
    final jokeRef = _db.collection('jokes').doc(jokeId);
    try {
      await _db.runTransaction((transaction) async {
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
    } catch (e) {
      debugPrint('Error in likeJoke transaction: $e');
      rethrow;
    }
  }

  /// Adds a comment and increments commentsCount atomically via WriteBatch.
  Future<void> addComment(Comment comment) async {
    // Censurer le commentaire
    final censoredComment = Comment(
      id: comment.id,
      jokeId: comment.jokeId,
      authorId: comment.authorId,
      authorName: comment.authorName,
      authorAvatarUrl: comment.authorAvatarUrl,
      content: _moderation.censorText(comment.content),
      createdAt: comment.createdAt,
    );

    final batch = _db.batch();
    final commentRef = _db.collection('comments').doc();
    final jokeRef = _db.collection('jokes').doc(censoredComment.jokeId);

    batch.set(commentRef, censoredComment.toMap());
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

  /// Returns jokes matching the query (limited to latest 200 for performance).
  Future<List<Joke>> searchJokes(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.trim().toLowerCase();

    // Note: To avoid OOM, we only search within the latest 200 jokes.
    final snapshot = await _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .limit(200)
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

  /// Efficiently returns a single random joke from the latest 200 jokes.
  Future<Joke?> getRandomJoke() async {
    final snapshot = await _db
        .collection('jokes')
        .orderBy('createdAt', descending: true)
        .limit(200)
        .get();

    final list = snapshot.docs.map(Joke.fromFirestore).toList();
    list.shuffle();
    return list.first;
  }

  /// Met à jour de façon atomique le badge vérifié sur toutes les blagues de l'auteur dans Firestore.
  Future<void> syncAuthorVerifiedJokes(String authorId, bool isVerified) async {
    try {
      final query = await _db
          .collection('jokes')
          .where('authorId', isEqualTo: authorId)
          .get();
      if (query.docs.isEmpty) return;
      final batch = _db.batch();
      var updateCount = 0;
      for (final doc in query.docs) {
        if (doc.data()['isAuthorVerified'] != isVerified) {
          batch.update(doc.reference, {'isAuthorVerified': isVerified});
          updateCount++;
        }
      }
      if (updateCount > 0) {
        await batch.commit();
        debugPrint('[JokeService] $updateCount blague(s) mise(s) à jour avec isAuthorVerified=$isVerified');
      }
    } catch (e) {
      debugPrint('[JokeService] syncAuthorVerifiedJokes error: $e');
    }
  }
}

