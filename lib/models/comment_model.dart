import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String jokeId;
  final String content;
  final String authorName;
  final String authorId;
  final String? authorAvatarUrl;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.jokeId,
    required this.content,
    required this.authorName,
    required this.authorId,
    this.authorAvatarUrl,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // createdAt may be null immediately after an optimistic write
    final ts = data['createdAt'];
    return Comment(
      id: doc.id,
      jokeId: data['jokeId'] ?? '',
      content: data['content'] ?? '',
      authorName: data['authorName'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      authorAvatarUrl: data['authorAvatarUrl'],
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jokeId': jokeId,
      'content': content,
      'authorName': authorName,
      'authorId': authorId,
      'authorAvatarUrl': authorAvatarUrl,
      // Use server timestamp for accurate ordering across devices
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
