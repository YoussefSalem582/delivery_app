import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/architecture/entities/order_entity.dart';
import 'package:delivery_app/core/architecture/repositories/auth_repository.dart';
import 'package:delivery_app/core/theme/theme_cubit.dart';
import 'package:delivery_app/core/utils/responsive.dart';
import 'package:delivery_app/core/utils/ui_helpers.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/profile/presentation/bloc/order_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          final user = snapshot.data;
          return Scaffold(
            appBar: AppBar(title: Text('profile_title'.tr())),
            body: Responsive.isTablet(context) || Responsive.isDesktop(context)
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _ProfileHeader(user: user)),
                      Expanded(child: _ProfileTabs(tabController: _tabController)),
                    ],
                  )
                : Column(
                    children: [
                      _ProfileHeader(user: user),
                      Expanded(child: _ProfileTabs(tabController: _tabController)),
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
    return Padding(
      padding: Responsive.pagePadding(context),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onLongPress: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TalkerScreen(talker: sl()),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 40,
                  child: Text(
                    (user?.name ?? 'D')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'demo_user'.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(user?.email ?? ''),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text('wallet'.tr()),
                trailing: Text(
                  '${user?.walletBalance?.toStringAsFixed(2) ?? '0.00'} EGP',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SwitchListTile(
                title: Text('dark_mode'.tr()),
                value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                onChanged: (v) => context.read<ThemeCubit>().toggleDark(v),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('language'.tr()),
                trailing: DropdownButton<String>(
                  value: context.watch<LocaleCubit>().state,
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
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.router.replaceAll([const LoginRoute()]);
                },
                icon: const Icon(Icons.logout),
                label: Text('logout'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'orders'.tr()),
            Tab(text: 'settings'.tr()),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return LoadingView(message: 'loading');
                  }
                  if (state is OrderLoaded) {
                    return ListView.separated(
                      padding: Responsive.pagePadding(context),
                      itemCount: state.orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return _OrderTile(order: order);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              ListView(
                padding: Responsive.pagePadding(context),
                children: [
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: Text('open_talker'.tr()),
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
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(order.title),
        subtitle: Text(_statusLabel(order.status)),
        trailing: Text('${order.amount.toStringAsFixed(2)} EGP'),
      ),
    );
  }
}
