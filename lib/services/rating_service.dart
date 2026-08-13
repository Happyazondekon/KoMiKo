import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:komiko/widgets/rating_dialog.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  static const String _keyActionCount = 'rating_action_count';
  static const String _keyHasRated = 'has_rated_app';
  static const String _keyNeverAsk = 'rating_never_ask';

  /// Increments action count and requests review if conditions are met.
  Future<void> maybeRequestReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_keyHasRated) ?? false) return;
      if (prefs.getBool(_keyNeverAsk) ?? false) return;

      int count = prefs.getInt(_keyActionCount) ?? 0;
      count++;
      await prefs.setInt(_keyActionCount, count);

      // Request review after 5 positive actions
      if (count >= 5) {
        // We can't show context-dependent UI from a singleton without context,
        // so we just return or handle it via a global key if needed.
        // For now, we rely on the manual trigger in settings or detail view.
      }
    } catch (e) {
      debugPrint('Error in maybeRequestReview: $e');
    }
  }

  /// Mark as rated to stop prompts
  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasRated, true);
  }

  /// Mark as never ask
  Future<void> markAsNeverAsk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNeverAsk, true);
  }

  /// Try to show the native Google Play review dialog
  Future<bool> requestNativeReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting native review: $e');
      return false;
    }
  }

  /// Open the custom stylized rating dialog
  Future<void> showRatingDialog(BuildContext context) async {
    await RatingDialog.show(context);
  }

  /// Force request review (e.g., from a button in settings)
  Future<void> forceRequestReview(BuildContext context) async {
    await showRatingDialog(context);
  }
}
