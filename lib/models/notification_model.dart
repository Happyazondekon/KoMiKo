import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String recipientId;
  final String type; // 'like' | 'comment' | 'daily_joke'
  final String actorId;
  final String actorName;
  final String? actorAvatarUrl;
  final String jokeId;
  final String? jokeContent;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.actorId,
    required this.actorName,
    this.actorAvatarUrl,
    required this.jokeId,
    this.jokeContent,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'];
    return AppNotification(
      id: doc.id,
      recipientId: data['recipientId'] as String? ?? '',
      type: data['type'] as String? ?? 'like',
      actorId: data['actorId'] as String? ?? '',
      actorName: data['actorName'] as String? ?? '',
      actorAvatarUrl: data['actorAvatarUrl'] as String?,
      jokeId: data['jokeId'] as String? ?? '',
      jokeContent: data['jokeContent'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'recipientId': recipientId,
        'type': type,
        'actorId': actorId,
        'actorName': actorName,
        'actorAvatarUrl': actorAvatarUrl,
        'jokeId': jokeId,
        'jokeContent': jokeContent,
        'isRead': isRead,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
