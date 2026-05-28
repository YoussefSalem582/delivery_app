import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

enum ProfileUserCardVariant { compact, hero }

/// User identity card — compact row (driver) or centered hero (passenger profile).
class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    required this.user,
    this.variant = ProfileUserCardVariant.compact,
    this.showPhone = true,
    this.onEdit,
  });

  final UserEntity user;
  final ProfileUserCardVariant variant;
  final bool showPhone;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      ProfileUserCardVariant.compact => _CompactUserCard(
          user: user,
          showPhone: showPhone,
        ),
      ProfileUserCardVariant.hero => _HeroUserHeader(
          user: user,
          onEdit: onEdit,
        ),
    };
  }
}

class _CompactUserCard extends StatelessWidget {
  const _CompactUserCard({
    required this.user,
    required this.showPhone,
  });

  final UserEntity user;
  final bool showPhone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          AvatarImage(
            imageUrl: user.avatarUrl,
            fallback: user.name,
            radius: 28,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                if (showPhone && user.phone.isNotEmpty)
                  Text(
                    user.phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroUserHeader extends StatelessWidget {
  const _HeroUserHeader({
    required this.user,
    this.onEdit,
  });

  final UserEntity user;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? scheme.outlineVariant.withValues(alpha: 0.5)
                      : scheme.surfaceContainerLowest,
                  width: 3,
                ),
                boxShadow: isDark
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: AvatarImage(
                imageUrl: user.avatarUrl,
                fallback: user.name,
                radius: 42,
              ),
            ),
            if (onEdit != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? scheme.primaryContainer : scheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.4 : 0.15,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.edit, size: 16, color: scheme.onPrimary),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(user.name, style: Theme.of(context).textTheme.titleLarge),
        Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
