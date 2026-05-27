import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tappable profile avatar for shell tab AppBars — navigates to the profile tab.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({
    super.key,
    this.radius = 16,
    this.child,
  });

  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.goNamed(RouteNames.profile),
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: Center(
              child: child ??
                  Icon(
                    Icons.person,
                    size: radius + 2,
                    color: scheme.primary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
