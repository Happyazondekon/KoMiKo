import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Shared helpers ─────────────────────────────────────────────

  static ElevatedButtonThemeData _elevatedBtn(Color bg, Color fg) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 16),
          elevation: 0,
        ),
      );

  static OutlinedButtonThemeData _outlinedBtn(
          Color fg, Color border) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, fontSize: 15),
        ),
      );

  static InputDecorationTheme _inputDecoration(
          Color fill, Color hint, Color label, Color border) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        labelStyle: GoogleFonts.poppins(color: hint, fontSize: 14),
        hintStyle: GoogleFonts.poppins(color: hint, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.error, width: 2),
        ),
      );

  static ChipThemeData _chipTheme(Color bg, Color label) =>
      ChipThemeData(
        backgroundColor: bg,
        labelStyle: GoogleFonts.poppins(
            color: label,
            fontSize: 12,
            fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );

  // ── Light theme ──────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: _inputDecoration(
        AppColors.lightSurface,
        AppColors.textSecondaryLight,
        AppColors.textPrimaryLight,
        AppColors.lightBorder,
      ),
      elevatedButtonTheme:
          _elevatedBtn(AppColors.primary, Colors.black),
      outlinedButtonTheme:
          _outlinedBtn(AppColors.primary, AppColors.primary),
      chipTheme: _chipTheme(
          AppColors.lightBorder, AppColors.textPrimaryLight),
      dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder, thickness: 1),
    );
  }

  // ── Dark theme ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme:
            const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: _inputDecoration(
        AppColors.darkSurface,
        AppColors.textSecondaryDark,
        AppColors.textPrimaryDark,
        AppColors.darkBorder,
      ),
      elevatedButtonTheme:
          _elevatedBtn(AppColors.primary, Colors.black),
      outlinedButtonTheme:
          _outlinedBtn(AppColors.primary, AppColors.darkBorder),
      chipTheme:
          _chipTheme(AppColors.darkCard, AppColors.textPrimaryDark),
      dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder, thickness: 1),
    );
  }
}
