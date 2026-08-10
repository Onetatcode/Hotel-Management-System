import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Outlined status pill (room, booking, payment statuses) in the neumorphic
/// palette. Unknown statuses fall back to neutral gray.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  static const Map<String, Color> _colors = {
    'available': AppColors.lime,
    'occupied': AppColors.softRed,
    'cleaning': AppColors.softBlue,
    'out_of_service': AppColors.textMuted,
    'booked': AppColors.textMuted,
    'checked_in': AppColors.lime,
    'checked_out': AppColors.textMuted,
    'cancelled': AppColors.softRed,
    'unpaid': AppColors.amber,
    'paid': AppColors.lime,
    'admin': AppColors.lime,
    'front_desk': AppColors.softBlue,
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status.toLowerCase()] ?? AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
