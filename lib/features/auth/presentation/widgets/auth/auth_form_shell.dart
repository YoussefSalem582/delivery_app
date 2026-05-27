import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:flutter/material.dart';

/// Shared card chrome for auth forms (login, register, forgot password).
class AuthFormShell extends StatelessWidget {
  const AuthFormShell({
    super.key,
    required this.titleKey,
    required this.subtitleKey,
    this.footer,
    required this.children,
  });

  final String titleKey;
  final String subtitleKey;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusSheet),
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
          Text(
            titleKey,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoktaSpacing.xs),
          Text(
            subtitleKey,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoktaSpacing.lg),
          ...children,
          if (footer != null) ...[
            const SizedBox(height: NoktaSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
