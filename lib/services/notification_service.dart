import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:komiko/models/notification_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _db = FirebaseFirestore.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'komiko_channel',
    'Komiko Notifications',
    description: 'Daily jokes and interactions',
    importance: Importance.high,
  );

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotif.initialize(initSettings);
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // ── Local: schedule daily joke notification ───────────────────────────────

  static Future<void> scheduleDailyJokeNotification({
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _localNotif.zonedSchedule(
      0,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelDailyJokeNotification() async {
    await _localNotif.cancel(0);
  }

  // ── Firestore: in-app notifications ──────────────────────────────────────

  /// Call after a like action. Creates a notification for the joke author.
  static Future<void> createLikeNotification({
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorAvatarUrl,
    required String jokeId,
    String? jokeContent,
  }) async {
    if (recipientId == actorId) return; // no self-notification
    try {
      final notif = AppNotification(
        id: '',
        recipientId: recipientId,
        type: 'like',
        actorId: actorId,
        actorName: actorName,
        actorAvatarUrl: actorAvatarUrl,
        jokeId: jokeId,
        jokeContent: jokeContent,
        createdAt: DateTime.now(),
      );
      await _db.collection('notifications').add(notif.toMap());
    } catch (_) {}
  }

  /// Call after a comment action.
  static Future<void> createCommentNotification({
    required String recipientId,
    required String actorId,
    required String actorName,
    String? actorAvatarUrl,
    required String jokeId,
    String? jokeContent,
  }) async {
    if (recipientId == actorId) return;
    try {
      final notif = AppNotification(
        id: '',
        recipientId: recipientId,
        type: 'comment',
        actorId: actorId,
        actorName: actorName,
        actorAvatarUrl: actorAvatarUrl,
        jokeId: jokeId,
        jokeContent: jokeContent,
        createdAt: DateTime.now(),
      );
      await _db.collection('notifications').add(notif.toMap());
    } catch (_) {}
  }

  /// Stream of notifications for a given user, newest first.
  static Stream<List<AppNotification>> getNotificationsStream(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(AppNotification.fromFirestore).toList());
  }

  /// Mark a single notification as read.
  static Future<void> markRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Mark all user notifications as read.
  static Future<void> markAllRead(String userId) async {
    final batch = _db.batch();
    final snaps = await _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snaps.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Count of unread notifications for a user.
  static Stream<int> unreadCountStream(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }
}
