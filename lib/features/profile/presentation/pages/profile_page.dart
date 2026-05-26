import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/theme/theme_cubit.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/profile/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<OrderBloc>()..add(const OrderLoadRequested())),
      ],
      child: FutureBuilder(
        future: sl<AuthRepository>().getProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(title: Text('profile_title'.tr())),
              body: Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(NoktaSpacing.md),
                  children: const [
                    SkeletonListTile(),
                    SizedBox(height: NoktaSpacing.lg),
                    SkeletonTripCard(),
                    SkeletonTripCard(),
                  ],
                ),
              ),
            );
          }

          final user = snapshot.data;
          final scheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Scaffold(
            backgroundColor: isDark ? scheme.surfaceContainerLow : scheme.surface,
            appBar: AppBar(
              backgroundColor: scheme.surface,
              title: Text('profile_title'.tr()),
              leading: IconButton(
                icon: Icon(Icons.menu, color: scheme.onSurfaceVariant),
                onPressed: () {},
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: NoktaSpacing.sm),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: scheme.surfaceContainerHigh,
                    child: Text(
                      (user?.name ?? 'D')[0].toUpperCase(),
                      style: TextStyle(color: scheme.primary, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(NoktaSpacing.md),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: NoktaSpacing.lg),
                _WalletCard(balance: user?.walletBalance ?? 0),
                const SizedBox(height: NoktaSpacing.lg),
                _TabBar(
                  selectedIndex: _tabIndex,
                  onChanged: (i) => setState(() => _tabIndex = i),
                ),
                const SizedBox(height: NoktaSpacing.md),
                if (_tabIndex == 0)
                  _OrdersTab()
                else
                  _SettingsTab(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final dynamic user;

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
                imageUrl: user?.avatarUrl,
                fallback: user?.name ?? 'D',
                radius: 42,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? scheme.primaryContainer : scheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.edit, size: 16, color: scheme.onPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: NoktaSpacing.sm),
        Text(user?.name ?? 'demo_user'.tr(), style: Theme.of(context).textTheme.titleLarge),
        Text(user?.email ?? 'demo@delivery.app', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [scheme.surfaceContainerHigh, scheme.surfaceContainer]
              : [scheme.surface, scheme.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 1),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.secondary.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text('balance'.tr(), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: NoktaSpacing.xs),
                    Text(
                      '${balance.toStringAsFixed(2)} EGP',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: scheme.onSurface,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: Text('top_up'.tr()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, NoktaSpacing.buttonHeight),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isDark ? scheme.primaryContainer : scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'orders'.tr(),
          selected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        _TabButton(
          label: 'settings'.tr(),
          selected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ].map((tab) => Expanded(child: tab)).toList(),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 1),
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return SizedBox(
            height: 200,
            child: Skeletonizer(
              enabled: true,
              child: ListView(
                children: const [
                  SkeletonListTile(),
                  SkeletonListTile(),
                ],
              ),
            ),
          );
        }
        if (state is OrderLoaded) {
          if (state.orders.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(NoktaSpacing.lg),
              child: Center(
                child: Text(
                  'no_orders'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            );
          }
          return Column(
            children: state.orders
                .map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: NoktaSpacing.sm),
                    child: _OrderTile(order: order),
                  ),
                )
                .toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.5),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'dark_mode'.tr(),
                showDivider: true,
                trailing: Switch.adaptive(
                  value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                  activeTrackColor: scheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: scheme.primary,
                  onChanged: (v) => context.read<ThemeCubit>().toggleDark(v),
                ),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'language'.tr(),
                showDivider: true,
                trailing: DropdownButton<String>(
                  value: context.watch<LocaleCubit>().state,
                  underline: const SizedBox.shrink(),
                  dropdownColor: isDark ? scheme.surfaceContainerHighest : null,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (code) {
                    if (code == null) return;
                    context.read<LocaleCubit>().setLocale(code);
                    context.setLocale(Locale(code));
                  },
                ),
              ),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'open_talker'.tr(),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TalkerScreen(talker: sl()),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: NoktaSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: NoktaSpacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.router.replaceAll([const LoginRoute()]);
            },
            icon: Icon(Icons.logout, color: scheme.error),
            label: Text(
              'logout'.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.45)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(icon, color: scheme.onSurfaceVariant),
          title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing: trailing ??
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
          ),
          hoverColor: isDark
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : scheme.surfaceContainerLow,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: NoktaSpacing.md,
            endIndent: NoktaSpacing.md,
            color: scheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.5),
          ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});

  final OrderEntity order;

  String _statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => 'order_delivered'.tr(),
      OrderStatus.pending => 'order_pending'.tr(),
      OrderStatus.inTransit => 'order_inTransit'.tr(),
    };
  }

  Color _statusColor(OrderStatus status, ColorScheme scheme) {
    return switch (status) {
      OrderStatus.delivered => scheme.secondary,
      OrderStatus.inTransit => scheme.secondaryContainer,
      OrderStatus.pending => scheme.onSurfaceVariant,
    };
  }

  Color _statusBg(OrderStatus status, ColorScheme scheme, bool isDark) {
    return switch (status) {
      OrderStatus.delivered => scheme.secondary.withValues(alpha: isDark ? 0.15 : 0.1),
      OrderStatus.inTransit => scheme.secondaryContainer.withValues(alpha: isDark ? 0.2 : 0.35),
      OrderStatus.pending => scheme.surfaceContainerHighest.withValues(alpha: isDark ? 0.6 : 1),
    };
  }

  IconData _statusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered => Icons.check_circle_outline,
      OrderStatus.inTransit => Icons.local_shipping_outlined,
      OrderStatus.pending => Icons.schedule,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(NoktaSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(NoktaSpacing.radiusMd),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.45 : 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusBg(order.status, scheme, isDark),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusIcon(order.status),
              size: 20,
              color: _statusColor(order.status, scheme),
            ),
          ),
          const SizedBox(width: NoktaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(order.status),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            '${order.amount.toStringAsFixed(2)} EGP',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
