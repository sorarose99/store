import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────
///  KDX STORE — App Theme
///
///  🎨 To change the primary brand color across the ENTIRE app:
///     Change [kSeedColor] below. One line. Done.
///
///  Light and Dark themes are both derived automatically from this seed
///  using Flutter's Material 3 color system.
/// ─────────────────────────────────────────────────────────────────
const Color kSeedColor = Color(0xFF43C1CD); // ← CHANGE THIS TO REBRAND

class AppTheme {
  AppTheme._();

  // ── Light Theme ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: Brightness.light,
    );
    return _buildTheme(colorScheme);
  }

  // ── Dark Theme ───────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: kSeedColor,
      brightness: Brightness.dark,
    );
    return _buildTheme(colorScheme);
  }

  // ── Shared builder ───────────────────────────────────────────────
  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),

      // Typography — Cairo for Arabic, fallback to Outfit for Latin
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        titleLarge: GoogleFonts.tajawal(
          fontSize: 22.0.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 16.0.sp,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 16.0.sp,
          color: colorScheme.onSurface,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 14.0.sp,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 16.0.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // Elevated Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: GoogleFonts.tajawal(
              fontSize: 16.0.sp, fontWeight: FontWeight.bold),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6FA),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5.w),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5.w),
        ),
        hintStyle: GoogleFonts.tajawal(
            color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
        labelStyle:
            GoogleFonts.tajawal(color: colorScheme.onSurface, fontSize: 14.sp),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primary,
        labelStyle:
            GoogleFonts.tajawal(fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
