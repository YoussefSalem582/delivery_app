import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/features/auth/shared/domain/entities/user_entity.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/core/widgets/avatar_image.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/shared/widgets/banners/offline_banner.dart';
import 'package:delivery_app/shared/widgets/inputs/app_text_field.dart';
import 'package:delivery_app/core/widgets/skeleton_trip_card.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/profile/orders/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/features/profile/profile_view/presentation/bloc/profile_bloc.dart';
import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:talker_flutter/talker_flutter.dart';

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
        BlocProvider(
          create: (_) => sl<ProfileBloc>()..add(const ProfileLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<OrderBloc>()..add(const OrderLoadRequested()),
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(title: Text('profile_title'.tr())),
              body: Skeletonizer(
                enabled: true,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: const [
                    SkeletonListTile(),
                    SizedBox(height: AppSpacing.lg),
                    SkeletonTripCard(),
                    SkeletonTripCard(),
                  ],
                ),
              ),
            );
          }
          if (state is ProfileError) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: AppBar(title: Text('profile_title'.tr())),
              body: ErrorView(
                message: state.message,
                onRetry: () => context
                    .read<ProfileBloc>()
                    .add(const ProfileLoadRequested()),
              ),
            );
          }
          if (state is ProfileLoaded) {
            return _ProfileContent(
              user: state.user,
              isOffline: state.isOffline,
              tabIndex: _tabIndex,
              onTabChanged: (i) => setState(() => _tabIndex = i),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.isOffline,
    required this.tabIndex,
    required this.onTabChanged,
  });

  final UserEntity user;
  final bool isOffline;
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? scheme.surfaceContainerLow : scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        automaticallyImplyLeading: false,
        leading: const ShellAppBarLogo(),
        title: Text('profile_title'.tr()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: scheme.surfaceContainerHigh,
              child: Text(
                user.name[0].toUpperCase(),
                style: TextStyle(color: scheme.primary, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (isOffline) const OfflineSectionBanner(),
          _ProfileHeader(user: user),
          const SizedBox(height: AppSpacing.lg),
          _WalletCard(balance: user.walletBalance),
          const SizedBox(height: AppSpacing.lg),
          _TabBar(
            selectedIndex: tabIndex,
            onChanged: onTabChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          if (tabIndex == 0) _OrdersTab() else _SettingsTab(user: user),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserEntity user;

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
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditProfileSheet(context, user),
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

class _WalletCard extends StatelessWidget {
  const _WalletCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [scheme.surfaceContainerHigh, scheme.surfaceContainer]
              : [scheme.surface, scheme.surfaceContainerHigh],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                    const SizedBox(height: AppSpacing.xs),
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
                onPressed: () => _showTopUpSheet(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text('top_up'.tr()),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppSpacing.buttonHeight),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: isDark ? scheme.primaryContainer : scheme.primary,
                  foregroundColor: scheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
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
            children: [
              if (state.isOffline) const OfflineSectionBanner(),
              ...state.orders.map(
                (order) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OrderTile(order: order),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Material(
          color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                  value: context.watch<SettingsCubit>().state.themeMode ==
                      ThemeMode.dark,
                  activeTrackColor: scheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: scheme.primary,
                  onChanged: (v) => context.read<SettingsCubit>().toggleDark(v),
                ),
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'language'.tr(),
                showDivider: true,
                trailing: DropdownButton<String>(
                  value: context.watch<SettingsCubit>().state.locale.languageCode,
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
                    context.read<SettingsCubit>().setLocale(Locale(code));
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
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.goNamed(RouteNames.splash);
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          hoverColor: isDark
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : scheme.surfaceContainerLow,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.md,
            endIndent: AppSpacing.md,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showOrderDetailsSheet(context, order),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
              const SizedBox(width: AppSpacing.sm),
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
        ),
      ),
    );
  }
}

void _showTopUpSheet(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  const amounts = [50.0, 100.0, 200.0];

  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'select_top_up_amount'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            ...amounts.map(
              (amount) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(color: scheme.outlineVariant),
                  ),
                  title: Text('${amount.toStringAsFixed(0)} EGP'),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.read<ProfileBloc>().add(
                          ProfileWalletTopUpRequested(amount: amount),
                        );
                    AppToast.success(context, 'wallet_top_up_success'.tr());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showEditProfileSheet(BuildContext context, UserEntity user) {
  final nameController = TextEditingController(text: user.name);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'edit_profile'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: nameController,
                  labelText: 'full_name'.tr(),
                  hintText: 'full_name_hint'.tr(),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.length < 2) {
                      AppToast.error(context, 'error_name_short'.tr());
                      return;
                    }
                    Navigator.of(sheetContext).pop();
                    context.read<ProfileBloc>().add(
                          ProfileUpdateRequested(name: name),
                        );
                    AppToast.success(context, 'profile_updated'.tr());
                  },
                  child: Text('save'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showOrderDetailsSheet(BuildContext context, OrderEntity order) {
  final dateFormat = DateFormat.yMMMd().add_jm();

  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'order_details'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(order.title),
              subtitle: Text(dateFormat.format(order.createdAt)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('status'.tr()),
              trailing: Text(_orderStatusLabel(order.status)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('fare'.tr()),
              trailing: Text('${order.amount.toStringAsFixed(2)} EGP'),
            ),
          ],
        ),
      ),
    ),
  );
}

String _orderStatusLabel(OrderStatus status) {
  return switch (status) {
    OrderStatus.delivered => 'order_delivered'.tr(),
    OrderStatus.pending => 'order_pending'.tr(),
    OrderStatus.inTransit => 'order_inTransit'.tr(),
  };
}
