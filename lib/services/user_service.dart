import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:komiko/models/user_model.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? _currentUser;

  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile(String uid) async {
    // Check if we already have the correct user or are already loading
    if (_isLoading) return;
    if (_currentUser != null && _currentUser!.uid == uid) return;

    _isLoading = true;
    notifyListeners();
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        
        // Ensure official account data is always correct if it's missing or wrong
        if (uid == 'UK42noQ7qiVt63v3PHHywdZQajS2' && 
            (_currentUser?.avatarUrl == null || !_currentUser!.isVerified)) {
           _currentUser = _currentUser!.copyWith(
            username: 'Komiko',
            isVerified: true,
            avatarUrl: 'asset:assets/images/Komiko.webp',
          );
          await _db.collection('users').doc(uid).update(_currentUser!.toMap());
        }
      } else {
        // Create default profile
        _currentUser = UserModel(uid: uid);
        
        // Special case for official Komiko account
        if (uid == 'UK42noQ7qiVt63v3PHHywdZQajS2') {
          _currentUser = _currentUser!.copyWith(
            username: 'Komiko',
            isVerified: true,
            avatarUrl: 'asset:assets/images/Komiko.webp',
          );
        }

        await _db.collection('users').doc(uid).set(_currentUser!.toMap());
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
