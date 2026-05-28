import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DriverProfileTabPage extends StatelessWidget {
  const DriverProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text('profile_title'.tr())),
            body: Center(child: Text('auth_required'.tr())),
          );
        }

        final user = authState.user;
        final trips = sl<TripRepository>().getCachedTrips();
        final earnings = TripQuery.completedDriverEarnings(trips, user.id);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            toolbarHeight: ShellAppBarLogo.tabToolbarHeight,
            leadingWidth: ShellAppBarLogo.leadingWidth,
            automaticallyImplyLeading: false,
            leading: const ShellAppBarLogo(),
            title: Text('driver_profile_title'.tr()),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _UserHeader(user: user),
              const SizedBox(height: AppSpacing.lg),
              _EarningsCard(earnings: earnings),
              const SizedBox(height: AppSpacing.lg),
              if (user.driverProfile != null) ...[
                _InfoTile(
                  icon: Icons.directions_car_outlined,
                  label: 'driver_vehicle'.tr(),
                  value: user.driverProfile!.vehicleMakeModel,
                ),
                _InfoTile(
                  icon: Icons.confirmation_number_outlined,
                  label: 'driver_onboarding_plate'.tr(),
                  value: user.driverProfile!.licensePlate,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('driver_switch_passenger_mode'.tr()),
                subtitle: Text('driver_switch_passenger_hint'.tr()),
                value: false,
                onChanged: (_) async {
                  await context.read<AppModeCubit>().resetToPassenger();
                  if (context.mounted) {
                    context.goNamed(RouteNames.home);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<AppModeCubit>().resetToPassenger();
                    if (!context.mounted) return;
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                    context.goNamed(RouteNames.splash);
                  },
                  icon: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    'logout'.tr(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final UserEntity user;

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

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({required this.earnings});

  final double earnings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: scheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'driver_total_earnings'.tr(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                Text(
                  '${earnings.toStringAsFixed(2)} EGP',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
