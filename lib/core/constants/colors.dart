import 'package:flutter/material.dart';

/// Namshe-inspired design token system.
/// All screens reference this file — change once, update everywhere.
class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary teal — CTAs, active states, badges
  static const Color primary = Color(0xFF43C1CD);

  /// Darker teal for gradients / pressed states
  static const Color primaryDark = Color(0xFF2FA8B4);

  /// Light teal for tinted backgrounds, chips
  static const Color primaryLight = Color(0xFFE8F9FA);

  // ── Accent ───────────────────────────────────────────────────────────────
  /// Sale/discount accent — Namshe red-orange
  static const Color accent = Color(0xFFFF6B6B);

  /// Success green — free delivery, confirmed states
  static const Color success = Color(0xFF00C48C);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Deep navy-black for headlines
  static const Color textDark = Color(0xFF1A1A2E);

  /// Mid-tone body text
  static const Color textMid = Color(0xFF4A4A68);

  /// Hint / subtitle grey
  static const Color textGrey = Color(0xFF9B9BB4);

  /// Very light grey for placeholders
  static const Color textGreyLight = Color(0xFFC7C7D9);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF2F3F8);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFFECEEF5);

  // ── Dark accents ──────────────────────────────────────────────────────────
  static const Color accentDark = Color(0xFF1A1A2E);

  // ── Social Buttons ────────────────────────────────────────────────────────
  static const Color appleBlack = Color(0xFF000000);
  static const Color googleWhite = Color(0xFFF2F3F8);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF3B30);
  static const Color inputBorderActive = primary;

  // ── Shadows ───────────────────────────────────────────────────────────────
  /// Standard card shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  /// Teal glow shadow for active/selected elements
  static const List<BoxShadow> tealGlowShadow = [
    BoxShadow(
      color: Color(0x3043C1CD),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// App bar / floating shadow
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
  ];
}
