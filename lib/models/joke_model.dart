import 'package:cloud_firestore/cloud_firestore.dart';

class Joke {
  final String id;
  final String content;
  final String? punchline;
  final String category;
  final String authorName;
  final String authorId;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;

  Joke({
    required this.id,
    required this.content,
    this.punchline,
    required this.category,
    required this.authorName,
    required this.authorId,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
  });

  factory Joke.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Joke(
      id: doc.id,
      content: data['content'] ?? '',
      punchline: data['punchline'],
      category: data['category'] ?? 'General',
      authorName: data['authorName'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'punchline': punchline,
      'category': category,
      'authorName': authorName,
      'authorId': authorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'likedBy': likedBy,
    };
  }
}
