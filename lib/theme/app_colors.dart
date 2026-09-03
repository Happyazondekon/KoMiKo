import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFFD700);      // Komiko gold
  static const Color primaryDark = Color(0xFFE6C200);  // hover/pressed

  // ── Interaction accents ────────────────────────────────────
  static const Color pink = Color(0xFFFF6B8A);   // likes / hearts
  static const Color blue = Color(0xFF7B8FF4);   // comments

  // ── Dark theme ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface    = Color(0xFF1A1A1A);
  static const Color darkCard       = Color(0xFF1E1E1E);
  static const Color darkBorder     = Color(0xFF2A2A2A);

  // ── Light theme ─────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF2F2F2);
  static const Color lightSurface    = Color(0xFFFFFFFF);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightBorder     = Color(0xFFE0E0E0);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimaryDark   = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF888888);
  static const Color textPrimaryLight  = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF888888);

  // ── Semantic ──────────────────────────────────────────────
  static const Color error   = Color(0xFFFF4444);
  static const Color success = Color(0xFF44CC88);

  // ── Category icon backgrounds ──────────────────────────────
  static const Color catAnimaux       = Color(0xFF3A6B47);
  static const Color catBelges        = Color(0xFF243A7A);
  static const Color catBlondes       = Color(0xFF7A2460);
  static const Color catInformatique  = Color(0xFF24507A);
  static const Color catMedecine      = Color(0xFF7A2424);
  static const Color catSport         = Color(0xFF24607A);
  static const Color catToto          = Color(0xFF4A247A);
  static const Color catManagement    = Color(0xFF5A5A24);
  static const Color catGeneral       = Color(0xFF3A3A5A);
  static const Color catOther         = Color(0xFF3A3A3A);

  // ── Aliases (backward-compat) ───────────────────────────────
  static const Color primaryYellow    = primary;
  static const Color accentYellow     = primaryDark;

  /// Returns the icon background color for a canonical category key.
  static Color forCategory(String category) {
    switch (category) {
      case 'Animaux':      return catAnimaux;
      case 'Belges':       return catBelges;
      case 'Blondes':      return catBlondes;
      case 'Informatique': return catInformatique;
      case 'Médecine':     return catMedecine;
      case 'Sport':        return catSport;
      case 'Toto':         return catToto;
      case 'Management':   return catManagement;
      case 'Général':      return catGeneral;
      default:             return catOther;
    }
  }
}

/// Helper pour les assets dynamiques selon le thème (sombre / clair).
class AppAssets {
  AppAssets._();

  /// Logo Komiko sans fond adapté au mode actif :
  /// - Dark mode  -> assets/images/Komiko nobg.webp
  /// - Light mode -> assets/images/Komiko wht no bg.webp
  static String komikoLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? 'assets/images/Komiko nobg.webp' : 'assets/images/Komiko wht no bg.webp';
  }

  /// Logo Komiko sans fond à partir d'un booléen isDark.
  static String komikoLogoForDark(bool isDark) {
    return isDark ? 'assets/images/Komiko nobg.webp' : 'assets/images/Komiko wht no bg.webp';
  }
}
