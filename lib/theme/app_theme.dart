import 'package:flutter/material.dart';

/// ZahidNotes app ke rang — website (zahidnotes.com) ki apni color scheme.
///
/// * Primary buttons: website ka red gradient #d60000 -> #7a0000
///   (site ke `.zn-chapter-btn` buttons wala gradient).
/// * Har class ka apna gradient website ke CSS se liya gaya hai.
class AppColors {
  static const Color primaryRed = Color(0xFFD60000);
  static const Color darkRed = Color(0xFF7A0000);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryRed, darkRed],
  );

  // Class gradients — zahidnotes.com ke CSS se (btn-9th / btn-10th / ...)
  static const LinearGradient ninthGradient = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
  );
  static const LinearGradient tenthGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
  static const LinearGradient firstYearGradient = LinearGradient(
    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
  );
  static const LinearGradient secondYearGradient = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  );

  static const Color background = Color(0xFFF6F7F9);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
}

class AppTheme {
  static ThemeData light() {
    const base = Colors.white;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        surface: base,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primaryRed,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primaryRed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
    );
  }
}
