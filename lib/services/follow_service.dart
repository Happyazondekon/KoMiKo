import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:komiko/services/notification_service.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUid => _auth.currentUser?.uid;

  /// Follow a user
  Future<void> followUser({
    required String targetUid,
    required String targetName,
    String? targetAvatar,
    required String currentUserName,
    String? currentUserAvatar,
  }) async {
    final uid = _currentUid;
    if (uid == null || uid == targetUid) return;

    final followRef = _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUid);
    final followerRef = _db
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(uid);
    final currentUserDoc = _db.collection('users').doc(uid);
    final targetUserDoc = _db.collection('users').doc(targetUid);

    try {
      await _db.runTransaction((transaction) async {
        // 1. Add to following
        transaction.set(followRef, {
          'uid': targetUid,
          'username': targetName,
          'avatarUrl': targetAvatar,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 2. Add to followers
        transaction.set(followerRef, {
          'uid': uid,
          'username': currentUserName,
          'avatarUrl': currentUserAvatar,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Update counts
        transaction.update(currentUserDoc, {
          'followingCount': FieldValue.increment(1),
        });
        transaction.update(targetUserDoc, {
          'followersCount': FieldValue.increment(1),
        });
      });

      // 4. Notify the target user
      NotificationService.createFollowNotification(
        recipientId: targetUid,
        actorId: uid,
        actorName: currentUserName,
        actorAvatarUrl: currentUserAvatar,
      );
    } catch (e) {
      debugPrint('Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String targetUid) async {
    final uid = _currentUid;
    if (uid == null) return;

    final followRef = _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUid);
    final followerRef = _db
        .collection('users')
        .doc(targetUid)
        .collection('followers')
        .doc(uid);
    final currentUserDoc = _db.collection('users').doc(uid);
    final targetUserDoc = _db.collection('users').doc(targetUid);

    try {
      await _db.runTransaction((transaction) async {
        final followSnap = await transaction.get(followRef);
        if (!followSnap.exists) return;

        // 1. Remove from following
        transaction.delete(followRef);

        // 2. Remove from followers
        transaction.delete(followerRef);

        // 3. Update counts
        transaction.update(currentUserDoc, {
          'followingCount': FieldValue.increment(-1),
        });
        transaction.update(targetUserDoc, {
          'followersCount': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Check if following
  Stream<bool> isFollowingStream(String targetUid) {
    final uid = _currentUid;
    if (uid == null) return Stream.value(false);

    return _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((snap) => snap.exists);
  }
}
