import 'package:flutter/material.dart';

/// Soft-neumorphic "black + lime" palette.
abstract final class AppColors {
  /// App background (near-black).
  static const Color background = Color(0xFF0E0F10);

  /// Raised surfaces / panels (app bar, nav bar, inputs).
  static const Color elevated = Color(0xFF161818);

  /// Card surfaces.
  static const Color surface = Color(0xFF1C1F1D);

  /// Subtle highlight used for neumorphic top-left light sources.
  static const Color highlight = Color(0xFF2A2D2A);

  /// Primary accent.
  static const Color lime = Color(0xFFB6FF3C);

  /// Primary text.
  static const Color textPrimary = Color(0xFFF2F2F0);

  /// Muted text / secondary elements.
  static const Color textMuted = Color(0xFF8A8D8A);

  /// Status: warning / unpaid.
  static const Color amber = Color(0xFFFFC24B);

  /// Status: error / destructive.
  static const Color softRed = Color(0xFFFF6B6B);

  /// Status: informational / cleaning / front desk.
  static const Color softBlue = Color(0xFF6BB8FF);
}
