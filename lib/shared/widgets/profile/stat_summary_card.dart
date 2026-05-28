import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Icon + label + amount summary (wallet balance, driver earnings, etc.).
class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.amountText,
    this.backgroundColor,
    this.gradient,
    this.iconColor,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String amountText;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final trailingWidget = trailing;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? scheme.primaryContainer.withValues(alpha: 0.35))
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          if (trailingWidget != null) trailingWidget,
        ],
      ),
    );
  }
}
