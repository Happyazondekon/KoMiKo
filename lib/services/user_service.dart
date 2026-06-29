import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komiko/models/user_model.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  Future<void> loadUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      } else {
        // Create default profile
        _currentUser = UserModel(uid: uid);
        await _db.collection('users').doc(uid).set(_currentUser!.toMap());
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> updateProfile({String? username, String? bio, String? avatarUrl}) async {
    if (_currentUser == null) return;

    try {
      Map<String, dynamic> updates = {};
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection('users').doc(_currentUser!.uid).update(updates);
      
      _currentUser = _currentUser!.copyWith(
        username: username,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  void clearCache() {
    _currentUser = null;
    notifyListeners();
  }
}
