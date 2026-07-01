import 'package:cloud_firestore/cloud_firestore.dart';

class Joke {
  final String id;

  // Primary (French) content — stored as 'contentFr' (+ legacy 'content' for compat)
  final String contentFr;
  final String? punchlineFr;

  // Optional English content — empty/null means fallback to French
  final String? contentEn;
  final String? punchlineEn;

  final String category;
  final String authorName;
  final String authorId;
  final String? authorAvatarUrl;
  final bool isAuthorVerified;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;

  Joke({
    required this.id,
    required this.contentFr,
    this.punchlineFr,
    this.contentEn,
    this.punchlineEn,
    required this.category,
    required this.authorName,
    required this.authorId,
    this.authorAvatarUrl,
    this.isAuthorVerified = false,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
  });

  // ── Backward-compat getters ───────────────────────────────────────────────
  /// Raw French content (legacy usage)
  String get content => contentFr;
  String? get punchline => punchlineFr;

  // ── Localisation helpers ─────────────────────────────────────────────────
  /// Returns the content in [langCode] ('en' or 'fr'), falling back to French.
  String localizedContent(String langCode) {
    if (langCode == 'en' && contentEn != null && contentEn!.isNotEmpty) {
      return contentEn!;
    }
    return contentFr;
  }

  /// Returns the punchline in [langCode], falling back to French.
  String? localizedPunchline(String langCode) {
    if (langCode == 'en' && punchlineEn != null && punchlineEn!.isNotEmpty) {
      return punchlineEn;
    }
    return punchlineFr;
  }

  // ── Firestore serialization ───────────────────────────────────────────────
  factory Joke.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'];
    return Joke(
      id: doc.id,
      // Support both 'contentFr' (new) and legacy 'content' field
      contentFr: (data['contentFr'] as String?)?.isNotEmpty == true
          ? data['contentFr'] as String
          : (data['content'] as String? ?? ''),
      punchlineFr: (data['punchlineFr'] as String?) ?? (data['punchline'] as String?),
      contentEn: data['contentEn'] as String?,
      punchlineEn: data['punchlineEn'] as String?,
      category: data['category'] as String? ?? 'Général',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      authorId: data['authorId'] as String? ?? '',
      authorAvatarUrl: data['authorAvatarUrl'] as String?,
      isAuthorVerified: data['isAuthorVerified'] as bool? ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Write both keys so legacy queries still work
      'content': contentFr,
      'contentFr': contentFr,
      'punchline': punchlineFr,
      'punchlineFr': punchlineFr,
      'contentEn': contentEn,
      'punchlineEn': punchlineEn,
      'category': category,
      'authorName': authorName,
      'authorId': authorId,
      'authorAvatarUrl': authorAvatarUrl,
      'isAuthorVerified': isAuthorVerified,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
    };
  }
}
