import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:komiko/generated/gen_l10n/app_localizations.dart';
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
    try {
      tz.initializeTimeZones();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      
      await _localNotif.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // Create channel explicitly for Android
      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
          
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
    }
  }

  static Future<bool> requestPermission() async {
    try {
      // 1. Request system notification permission (Android 13+)
      final status = await Permission.notification.request();
      
      // 2. Also request Exact Alarm permission (for scheduled jokes)
      // This is now required for exact timing on modern Android
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }

      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  // ── Testing Methods ───────────────────────────────────────────────────────

  static Future<void> sendImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotif.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> scheduleTestNotification({
    required String title,
    required String body,
    required int delaySeconds,
  }) async {
    final scheduled = tz.TZDateTime.now(tz.local).add(Duration(seconds: delaySeconds));
    
    await _localNotif.zonedSchedule(
      999, // Test ID
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
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  // ── Local: schedule recurring notifications ─────────────────────────────

  /// Schedules 3 daily notifications to keep users engaged.
  /// 10:00, 14:00, and 19:00
  static Future<void> scheduleMultipleDailyNotifications(AppLocalizations l10n) async {
    final times = [
      {'id': 101, 'hour': 10, 'minute': 0, 'title': l10n.notifMorningTitle, 'body': l10n.notifMorningBody},
      {'id': 102, 'hour': 14, 'minute': 0, 'title': l10n.notifAfternoonTitle, 'body': l10n.notifAfternoonBody},
      {'id': 103, 'hour': 19, 'minute': 0, 'title': l10n.notifEveningTitle, 'body': l10n.notifEveningBody},
    ];

    for (final time in times) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time['hour'] as int,
        time['minute'] as int,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _localNotif.zonedSchedule(
        time['id'] as int,
        time['title'] as String,
        time['body'] as String,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(time['body'] as String),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    debugPrint('3 Daily notifications scheduled');
  }

  static Future<void> scheduleDailyJokeNotification({
    required String title,
    required String body,
    int hour = 9,
    int minute = 0,
  }) async {
    // Keeping this for potential specific admin-driven triggers
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
