import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:komiko/models/user_model.dart';
import 'package:komiko/services/joke_service.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  UserModel? _currentUser;
  StreamSubscription<DocumentSnapshot>? _userSubscription;

  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  /// True si le compte connecté est le compte admin Komiko.
  bool get isAdmin =>
      _currentUser?.role == 'komiko' ||
      _currentUser?.email?.trim().toLowerCase() == 'contact@komiko.app' ||
      _currentUser?.uid == 'UK42noQ7qiVt63v3PHHywdZQajS2';

  /// Dérive un nom d'utilisateur propre à partir de FirebaseAuth (displayName ou nom du mail).
  static String deriveUsernameFromAuth(User? authUser) {
    if (authUser == null) return 'Komikonaute';

    // 1. Priorité au displayName (nom saisi à l'inscription ou compte Google)
    final displayName = authUser.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    // 2. Extraire le préfixe de l'adresse email (ex: alex.dupont@gmail.com -> alex.dupont)
    final email = authUser.email?.trim();
    if (email != null && email.contains('@')) {
      final prefix = email.split('@').first.trim();
      if (prefix.isNotEmpty) {
        return prefix;
      }
    }

    return 'Komikonaute';
  }

  Future<void> loadUserProfile(String uid, {bool forceReload = false}) async {
    // Check if we already have the correct user or are already loading
    if (_isLoading) return;
    if (!forceReload && _currentUser != null && _currentUser!.uid == uid) return;

    _isLoading = true;
    notifyListeners();
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);

        // Écoute en temps réel pour synchroniser immédiatement les changements (ex: badge vérifié, statut Pro)
        _userSubscription?.cancel();
        _userSubscription = _db.collection('users').doc(uid).snapshots().listen((snapshot) {
          if (snapshot.exists) {
            _currentUser = UserModel.fromFirestore(snapshot);
            if (_currentUser!.effectiveIsVerified) {
              JokeService().syncAuthorVerifiedJokes(uid, true);
            }
            notifyListeners();
          }
        });
        
        if (_currentUser!.effectiveIsVerified) {
          JokeService().syncAuthorVerifiedJokes(uid, true);
        }

        // Ensure official account data is always correct if it's missing or wrong
        final isContactAccount = uid == 'UK42noQ7qiVt63v3PHHywdZQajS2' ||
            authUser?.email?.trim().toLowerCase() == 'contact@komiko.app' ||
            _currentUser?.email?.trim().toLowerCase() == 'contact@komiko.app';

        if (isContactAccount && 
            (_currentUser?.avatarUrl == null || !_currentUser!.isVerified || !_currentUser!.isPro)) {
           _currentUser = _currentUser!.copyWith(
            username: _currentUser?.username ?? 'Komiko',
            isVerified: true,
            isPro: true,
            role: 'komiko',
            avatarUrl: _currentUser?.avatarUrl ?? 'asset:assets/images/Komiko.webp',
          );
          await _db.collection('users').doc(uid).update({
            'isVerified': true,
            'isPro': true,
            'role': 'komiko',
            if (_currentUser?.avatarUrl == null)
              'avatarUrl': 'asset:assets/images/Komiko.webp',
          });
        }

        // Si l'utilisateur n'a pas de nom ou a un nom 'user' par défaut, on met à jour avec le nom du mail
        final currentUsername = _currentUser?.username?.trim();
        if (currentUsername == null ||
            currentUsername.isEmpty ||
            currentUsername.toLowerCase() == 'user' ||
            currentUsername.toLowerCase() == 'utilisateur') {
          final newName = deriveUsernameFromAuth(authUser);
          _currentUser = _currentUser!.copyWith(
            username: newName,
            email: _currentUser?.email ?? authUser?.email,
            avatarUrl: _currentUser?.avatarUrl ?? authUser?.photoURL,
          );
          await _db.collection('users').doc(uid).update({
            'username': newName,
            if (_currentUser?.email == null && authUser?.email != null)
              'email': authUser!.email,
          });
        }
      } else {
        // Create default profile with intelligent username
        final defaultUsername = deriveUsernameFromAuth(authUser);
        _currentUser = UserModel(
          uid: uid,
          email: authUser?.email,
          username: defaultUsername,
          avatarUrl: authUser?.photoURL,
        );
        
        // Special case for official Komiko account
        if (uid == 'UK42noQ7qiVt63v3PHHywdZQajS2') {
          _currentUser = _currentUser!.copyWith(
            username: 'Komiko',
            isVerified: true,
            role: 'komiko',
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
    _userSubscription?.cancel();
    _userSubscription = null;
    _currentUser = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  // ── Méthodes de lecture (admin) ────────────────────────────────────────────

  /// Charge un profil utilisateur par son UID (pour l'admin dashboard).
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getUserById: $e');
      return null;
    }
  }

  /// Recherche des utilisateurs par username ou email.
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final lower = query.trim().toLowerCase();
    try {
      final snapshot = await _db
          .collection('users')
          .orderBy('username')
          .limit(100)
          .get();
      return snapshot.docs
          .map(UserModel.fromFirestore)
          .where((u) =>
              (u.username?.toLowerCase().contains(lower) ?? false) ||
              (u.email?.toLowerCase().contains(lower) ?? false))
          .toList();
    } catch (e) {
      debugPrint('Error searchUsers: $e');
      return [];
    }
  }

  /// Récupère tous les utilisateurs (pour l'admin).
  Stream<List<UserModel>> get allUsersStream {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map(UserModel.fromFirestore).toList());
  }

  // ── Actions admin ──────────────────────────────────────────────────────────

  /// Restreint un utilisateur (ne peut plus poster ni commenter).
  Future<void> restrictUser(String uid, {String? reason}) async {
    await _db.collection('users').doc(uid).update({
      'isRestricted': true,
      'restrictedAt': FieldValue.serverTimestamp(),
      if (reason != null) 'banReason': reason,
    });
  }

  /// Lève la restriction d'un utilisateur.
  Future<void> unrestrictUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isRestricted': false,
      'restrictedAt': null,
      'banReason': null,
    });
  }

  /// Bannit complètement un utilisateur.
  Future<void> banUser(String uid, {String? reason}) async {
    await _db.collection('users').doc(uid).update({
      'isBanned': true,
      'bannedAt': FieldValue.serverTimestamp(),
      if (reason != null) 'banReason': reason,
    });
  }

  /// Lève le bannissement d'un utilisateur.
  Future<void> unbanUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isBanned': false,
      'bannedAt': null,
      'banReason': null,
    });
  }

  /// Accorde ou retire le badge vérifié à un utilisateur.
  Future<void> setVerified(String uid, bool verified) async {
    await _db.collection('users').doc(uid).update({'isVerified': verified});
  }

  /// Accorde le statut Pro à un utilisateur (sans passer par le billing).
  Future<void> grantPro(String uid, {DateTime? expiry}) async {
    await _db.collection('users').doc(uid).update({
      'isPro': true,
      'proExpiry': expiry != null ? Timestamp.fromDate(expiry) : null,
    });
  }

  /// Retire le statut Pro d'un utilisateur.
  Future<void> revokePro(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isPro': false,
      'proExpiry': null,
    });
  }
}
