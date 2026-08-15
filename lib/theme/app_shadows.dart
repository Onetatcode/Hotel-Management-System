import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Soft neumorphic shadow helpers: a dark bottom-right drop shadow plus a
/// faint top-left highlight, with no hairline borders.
class NeumorphicBox {
  const NeumorphicBox._();

  /// Raised surface shadow (cards, buttons, nav pill).
  static List<BoxShadow> raised({
    double blur = 16,
    double offset = 8,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.45),
        offset: Offset(offset * 0.75, offset),
        blurRadius: blur,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: AppColors.highlight.withValues(alpha: 0.45),
        offset: Offset(-offset * 0.5, -offset * 0.5),
        blurRadius: blur * 0.5,
      ),
    ];
  }

  /// Inset shadow (search bars, pressed states).
  static List<BoxShadow> inset({
    double blur = 10,
    double offset = 5,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5),
        offset: Offset(offset * 0.8, offset),
        blurRadius: blur,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: AppColors.highlight.withValues(alpha: 0.2),
        offset: Offset(-offset * 0.6, -offset * 0.6),
        blurRadius: blur * 0.8,
      ),
    ];
  }
}
