import 'package:flutter/material.dart';

/// Small colored status chip used across the app (room, booking, payment
/// statuses). Unknown statuses fall back to a neutral gray.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  static const Map<String, Color> _colors = {
    'available': Color(0xFF2E7D32),
    'occupied': Color(0xFFC62828),
    'cleaning': Color(0xFF1565C0),
    'out_of_service': Color(0xFF616161),
    'booked': Color(0xFF1565C0),
    'checked_in': Color(0xFF00838F),
    'checked_out': Color(0xFF616161),
    'cancelled': Color(0xFFC62828),
    'unpaid': Color(0xFFEF6C00),
    'paid': Color(0xFF2E7D32),
    'admin': Color(0xFF283593),
    'front_desk': Color(0xFF00838F),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[status.toLowerCase()] ?? Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
