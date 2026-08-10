import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';
import '../theme/app_theme.dart';

/// Neumorphic raised card: dark surface, soft drop + highlight shadow,
/// generous radius, no hairline borders.
class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.radius = AppSpacing.radiusCard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
        boxShadow: NeumorphicBox.raised(),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
