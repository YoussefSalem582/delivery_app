import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Shared card chrome for auth forms (login, register, forgot password).
class AuthFormShell extends StatelessWidget {
  const AuthFormShell({
    super.key,
    this.titleKey,
    this.subtitleKey,
    this.showHeader = true,
    this.footer,
    required this.children,
  });

  final String? titleKey;
  final String? subtitleKey;
  final bool showHeader;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader && titleKey != null) ...[
            Text(
              titleKey!,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitleKey != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitleKey!,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
          ...children,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
