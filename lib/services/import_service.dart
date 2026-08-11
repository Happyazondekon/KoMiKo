import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:komiko/models/joke_model.dart';
import 'package:komiko/services/joke_service.dart';

class ImportService {
  // ══ IMPORTANT ══════════════════════════════════════════════════
  // Replace with the Firebase UID of the official Komiko account.
  // Steps:
  //   1. Create a Firebase Auth account in Firebase Console.
  //   2. Copy the UID shown in the Users tab.
  //   3. Paste it below and set isVerified=true on that Firestore user document.
  static const String kKomikoUid = 'UK42noQ7qiVt63v3PHHywdZQajS2';
  static const String kKomikoName = 'Komiko';
  // ══════════════════════════════════════════════════════

  /// Imports all jokes from [assets/jokes_import.json] into Firestore.
  /// Jokes are attributed to the official Komiko account with a verified badge.
  ///
  /// [onProgress] receives:
  ///   - (current, total, isImporting)
  static Future<void> importInitialJokes({
    void Function(int current, int total, bool isImporting)? onProgress,
  }) async {
    final jokeService = JokeService();

    // 1. Cleanup old data with progress reporting
    await _cleanupOldJokes(onProgress);

    // 2. Load JSON from Flutter assets
    final String jsonString =
        await rootBundle.loadString('assets/jokes_import.json');
    final List<dynamic> raw = json.decode(jsonString) as List<dynamic>;
    final int total = raw.length;
    
    debugPrint('[ImportService] Loaded JSON from assets. Total jokes found in file: $total');

    onProgress?.call(0, total, true);

    // 3. Import jokes one by one
    for (var i = 0; i < raw.length; i++) {
      final map = raw[i] as Map<String, dynamic>;
      final joke = Joke(
        id: '',
        contentFr: map['contentFr'] as String? ?? '',
        punchlineFr: _nullIfEmpty(map['punchlineFr'] as String?),
        contentEn: _nullIfEmpty(map['contentEn'] as String?),
        punchlineEn: _nullIfEmpty(map['punchlineEn'] as String?),
        category: map['category'] as String? ?? 'Général',
        authorName: kKomikoName,
        authorId: kKomikoUid,
        authorAvatarUrl: 'asset:assets/images/Komiko.webp',
        isAuthorVerified: true,
        createdAt: DateTime.now(),
      );
      await jokeService.addJoke(joke);
      onProgress?.call(i + 1, total, true);
    }
  }

  static Future<void> _cleanupOldJokes(
      void Function(int current, int total, bool isImporting)? onProgress) async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;

    if (currentUser == null) return;

    debugPrint('[ImportService] STARTING TOTAL DATABASE RESET');

    // Get total count for progress bar (sum of jokes, comments, notifications)
    // Using a try-catch because count() might require specific permissions or indexes
    int jokesCount = 0;
    int commentsCount = 0;
    int notifsCount = 0;

    try {
      jokesCount = (await db.collection('jokes').count().get()).count ?? 0;
      commentsCount = (await db.collection('comments').count().get()).count ?? 0;
      notifsCount = (await db.collection('notifications').count().get()).count ?? 0;
    } catch (e) {
      debugPrint('[ImportService] Warning: Could not get exact counts for progress bar. Using estimates.');
      // Fallback to estimated counts if permission denied (likely for 9971 jokes)
      jokesCount = 10000; 
      commentsCount = 1000;
      notifsCount = 1000;
    }
    
    final int totalToDelete = jokesCount + commentsCount + notifsCount;
    int deletedCount = 0;

    onProgress?.call(0, totalToDelete, false);

    // Helper to wipe a collection in batches and report progress
    Future<void> wipeCollection(String collectionName) async {
      try {
        bool hasMore = true;
        while (hasMore) {
          final snaps = await db.collection(collectionName).limit(400).get();
          if (snaps.docs.isEmpty) {
            hasMore = false;
            break;
          }
          final batch = db.batch();
          for (final doc in snaps.docs) {
            batch.delete(doc.reference);
          }
          await batch.commit();
          deletedCount += snaps.docs.length;
          final current = deletedCount > totalToDelete ? totalToDelete : deletedCount;
          onProgress?.call(current, totalToDelete, false);
          debugPrint('[ImportService] Deleted batch from $collectionName.');
        }
      } catch (e) {
        debugPrint('[ImportService] Warning: Could not wipe collection $collectionName: $e');
        // Continue to the next collection/phase instead of crashing
      }
    }

    await wipeCollection('jokes');
    await wipeCollection('comments');
    await wipeCollection('notifications');

    debugPrint('[ImportService] DATABASE WIPE COMPLETE.');
  }

  static String? _nullIfEmpty(String? s) =>
      (s == null || s.isEmpty) ? null : s;
}
