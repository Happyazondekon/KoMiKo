import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  ///   - (-1, -1)  → cleanup phase
  ///   - (0,  N)   → JSON loaded, about to start importing N jokes
  ///   - (X,  N)   → joke X of N imported
  static Future<void> importInitialJokes({
    void Function(int current, int total)? onProgress,
  }) async {
    final jokeService = JokeService();

    // 1. Cleanup old test data (Komiko Bot / system)
    onProgress?.call(-1, -1);
    await _cleanupOldJokes();

    // 2. Load JSON from Flutter assets
    final String jsonString =
        await rootBundle.loadString('assets/jokes_import.json');
    final List<dynamic> raw = json.decode(jsonString) as List<dynamic>;
    final int total = raw.length;
    onProgress?.call(0, total);

    // 3. Import jokes one by one, reporting progress
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
      onProgress?.call(i + 1, total);
    }
  }

  static Future<void> _cleanupOldJokes() async {
    final db = FirebaseFirestore.instance;
    // Delete jokes originally seeded with authorId='system' (old Komiko Bot data)
    final snaps = await db
        .collection('jokes')
        .where('authorId', isEqualTo: 'system')
        .get();

    if (snaps.docs.isEmpty) return;

    // Firestore batch limit = 500 — split if needed
    const batchSize = 499;
    for (var i = 0; i < snaps.docs.length; i += batchSize) {
      final batch = db.batch();
      final chunk = snaps.docs.skip(i).take(batchSize);
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      try {
        await batch.commit();
      } catch (e) {
        // Log and continue — don't block the import
        debugPrint('[ImportService] Cleanup error (batch $i): $e');
      }
    }
  }

  static String? _nullIfEmpty(String? s) =>
      (s == null || s.isEmpty) ? null : s;
}
