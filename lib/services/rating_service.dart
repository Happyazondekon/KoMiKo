import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  static final RatingService _instance = RatingService._internal();
  factory RatingService() => _instance;
  RatingService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  static const String _keyActionCount = 'rating_action_count';
  static const String _keyHasRated = 'has_rated_app';

  /// Increments action count and requests review if conditions are met.
  /// Trigger this after positive actions (e.g., liking a joke).
  Future<void> maybeRequestReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Don't ask again if already rated
      if (prefs.getBool(_keyHasRated) ?? false) return;

      int count = prefs.getInt(_keyActionCount) ?? 0;
      count++;
      await prefs.setInt(_keyActionCount, count);

      // Request review after 5 positive actions
      if (count >= 5) {
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
          await prefs.setBool(_keyHasRated, true);
        }
      }
    } catch (e) {
      debugPrint('Error requesting review: $e');
    }
  }

  /// Force request review (e.g., from a button in settings)
  Future<void> forceRequestReview() async {
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
    } else {
      // Fallback: open store page
      await _inAppReview.openStoreListing(appStoreId: 'com.heyhappy.komiko');
    }
  }
}
