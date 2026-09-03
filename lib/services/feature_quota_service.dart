import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:komiko/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gère le système freemium des quotas d'utilisation (5 essais gratuits chacun pour la Photo et l'Assistant Komiko).
class FeatureQuotaService {
  static const int maxFreeUses = 5;

  static const String _keyPhotoUsedPrefix = 'free_photo_used_';
  static const String _keyAssistantUsedPrefix = 'free_assistant_used_';

  static final FeatureQuotaService instance = FeatureQuotaService._internal();
  FeatureQuotaService._internal();

  String _userKey(String? uid) => (uid != null && uid.isNotEmpty) ? uid : 'anonymous';

  /// Retourne le nombre d'utilisations consommées pour les photos
  Future<int> getPhotoUsedCount(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPhotoUsedPrefix${_userKey(uid)}';
    int local = prefs.getInt(key) ?? 0;

    // Synchronisation Firestore si utilisateur connecté
    if (uid != null && uid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final server = (doc.data()?['photoUsesCount'] as num?)?.toInt() ?? 0;
          if (server > local) {
            local = server;
            await prefs.setInt(key, local);
          }
        }
      } catch (e) {
        debugPrint('[FeatureQuotaService] Erreur sync photo: $e');
      }
    }
    return local;
  }

  /// Retourne le nombre d'utilisations consommées pour l'Assistant Komiko
  Future<int> getAssistantUsedCount(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyAssistantUsedPrefix${_userKey(uid)}';
    int local = prefs.getInt(key) ?? 0;

    // Synchronisation Firestore si utilisateur connecté
    if (uid != null && uid.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final server = (doc.data()?['assistantUsesCount'] as num?)?.toInt() ?? 0;
          if (server > local) {
            local = server;
            await prefs.setInt(key, local);
          }
        }
      } catch (e) {
        debugPrint('[FeatureQuotaService] Erreur sync assistant: $e');
      }
    }
    return local;
  }

  /// Nombre d'essais gratuits restants pour la photo (0..5)
  Future<int> getRemainingPhotoUses(String? uid) async {
    final used = await getPhotoUsedCount(uid);
    final remaining = maxFreeUses - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// Nombre d'essais gratuits restants pour l'Assistant Komiko (0..5)
  Future<int> getRemainingAssistantUses(String? uid) async {
    final used = await getAssistantUsedCount(uid);
    final remaining = maxFreeUses - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// Consomme un essai gratuit pour la photo
  Future<int> consumePhotoUse(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPhotoUsedPrefix${_userKey(uid)}';
    final current = prefs.getInt(key) ?? 0;
    final updated = current + 1;
    await prefs.setInt(key, updated);

    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'photoUsesCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FeatureQuotaService] Erreur increment photo Firestore: $e');
      }
    }
    final remaining = maxFreeUses - updated;
    return remaining < 0 ? 0 : remaining;
  }

  /// Consomme un essai gratuit pour l'Assistant Komiko
  Future<int> consumeAssistantUse(String? uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyAssistantUsedPrefix${_userKey(uid)}';
    final current = prefs.getInt(key) ?? 0;
    final updated = current + 1;
    await prefs.setInt(key, updated);

    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'assistantUsesCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FeatureQuotaService] Erreur increment assistant Firestore: $e');
      }
    }
    final remaining = maxFreeUses - updated;
    return remaining < 0 ? 0 : remaining;
  }

  /// Vérifie si l'utilisateur a droit à la photo (Pro illimité OU crédits restants)
  Future<bool> canUsePhoto(UserModel? user) async {
    if (user != null && user.hasActivePro) return true;
    final remaining = await getRemainingPhotoUses(user?.uid);
    return remaining > 0;
  }

  /// Vérifie si l'utilisateur a droit à l'Assistant Komiko (Pro illimité OU crédits restants)
  Future<bool> canUseAssistant(UserModel? user) async {
    if (user != null && user.hasActivePro) return true;
    final remaining = await getRemainingAssistantUses(user?.uid);
    return remaining > 0;
  }
}
