import 'package:flutter/material.dart';
import 'app_colors.dart';

class BubbleTheme {
  BubbleTheme._();

  static const double radiusSmall  = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge  = 24.0;
  static const double radiusPill   = 999.0;

  static Color get primaryShadow => const Color(0xFFB8860B); // Darker gold
  static Color get pinkShadow    => const Color(0xFFD81B60); // Darker pink
  static Color get blueShadow    => const Color(0xFF3F51B5); // Darker blue
  static Color get errorShadow   => const Color(0xFFA63030); // Darker red
  static const Color disabledShadow = Color(0xFFAAAAAA);

  static List<BoxShadow> shadowsFor({
    required Color shadowColor,
    double solidOffset = 5.0,
  }) {
    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: 0,
        offset: Offset(0, solidOffset),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.18),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> disabledShadows() {
    return [
      const BoxShadow(
        color: Color(0x22000000),
        blurRadius: 4,
        offset: Offset(0, 1),
      ),
    ];
  }
}

enum BubbleVariant { primary, pink, blue, danger, secondary }

extension BubbleVariantColors on BubbleVariant {
  Color get color {
    switch (this) {
      case BubbleVariant.primary:   return AppColors.primary;
      case BubbleVariant.pink:      return AppColors.pink;
      case BubbleVariant.blue:      return AppColors.blue;
      case BubbleVariant.danger:    return AppColors.error;
      case BubbleVariant.secondary: return const Color(0xFFEFEFEF);
    }
  }

  Color get shadowColor {
    switch (this) {
      case BubbleVariant.primary:   return BubbleTheme.primaryShadow;
      case BubbleVariant.pink:      return BubbleTheme.pinkShadow;
      case BubbleVariant.blue:      return BubbleTheme.blueShadow;
      case BubbleVariant.danger:    return BubbleTheme.errorShadow;
      case BubbleVariant.secondary: return const Color(0xFFCCCCCC);
    }
  }

  Color get foreground {
    switch (this) {
      case BubbleVariant.primary:   return Colors.black;
      case BubbleVariant.secondary: return Colors.black87;
      default:                      return Colors.white;
    }
  }
}
