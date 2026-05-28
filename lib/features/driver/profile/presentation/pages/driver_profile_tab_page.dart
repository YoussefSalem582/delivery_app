import 'package:delivery_app/features/auth/shared/presentation/utils/app_logout.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/trip_repository.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/shared/widgets/feedback/empty_state_view.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_app_bar.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_tab_scaffold.dart';
import 'package:delivery_app/shared/widgets/profile/app_mode_switch_tile.dart';
import 'package:delivery_app/shared/widgets/profile/logout_button.dart';
import 'package:delivery_app/shared/widgets/profile/profile_user_card.dart';
import 'package:delivery_app/shared/widgets/profile/stat_summary_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DriverProfileTabPage extends StatelessWidget {
  const DriverProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return ShellTabScaffold(
            appBar: ShellTabAppBar(title: Text('profile_title'.tr())),
            body: EmptyStateView(
              icon: Icons.lock_outline,
              title: 'auth_required'.tr(),
            ),
          );
        }

        final user = authState.user;
        final trips = sl<TripRepository>().getCachedTrips();
        final earnings = TripQuery.completedDriverEarnings(trips, user.id);

        return ShellTabScaffold(
          appBar: ShellTabAppBar(title: Text('driver_profile_title'.tr())),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              ProfileUserCard(user: user),
              const SizedBox(height: AppSpacing.lg),
              StatSummaryCard(
                icon: Icons.payments_outlined,
                label: 'driver_total_earnings'.tr(),
                amountText: '${earnings.toStringAsFixed(2)} EGP',
              ),
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
              const AppModeSwitchTile.driver(),
              const SizedBox(height: AppSpacing.lg),
              LogoutButton(onPressed: () => performAppLogout(context)),
            ],
          ),
        );
      },
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
