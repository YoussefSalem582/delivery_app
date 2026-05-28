import 'package:delivery_app/core/constants/app_constants.dart';
import 'package:delivery_app/config/routes/app_router.dart';
import 'package:delivery_app/config/theme/app_theme.dart';
import 'package:delivery_app/core/network/connectivity_cubit.dart';
import 'package:delivery_app/core/network/connectivity_state.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/notifications/notification_list/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:delivery_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:delivery_app/features/auth/shared/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/trips/trip_list/presentation/bloc/trip_list_bloc.dart';
import 'package:delivery_app/features/driver/jobs/presentation/bloc/driver_jobs_bloc.dart';
import 'package:delivery_app/features/driver/offers/presentation/bloc/driver_offers_bloc.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/driver_availability_cubit.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/shared/widgets/banners/offline_banner.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NoktaApp extends StatefulWidget {
  const NoktaApp({super.key});

  @override
  State<NoktaApp> createState() => _NoktaAppState();
}

class _NoktaAppState extends State<NoktaApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<NotificationBloc>().add(const NotificationLoadRequested());
      sl<TripListBloc>().add(const TripListLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityCubit>.value(value: sl<ConnectivityCubit>()),
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
        BlocProvider<SettingsCubit>.value(value: sl<SettingsCubit>()),
        BlocProvider<AppModeCubit>.value(value: sl<AppModeCubit>()),
        BlocProvider<DriverAvailabilityCubit>.value(
          value: sl<DriverAvailabilityCubit>(),
        ),
        BlocProvider<NotificationBloc>.value(value: sl<NotificationBloc>()),
        BlocProvider<TripListBloc>.value(value: sl<TripListBloc>()),
        BlocProvider<DriverJobsBloc>.value(value: sl<DriverJobsBloc>()),
        BlocProvider<DriverOffersBloc>.value(value: sl<DriverOffersBloc>()),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) => prev.locale != curr.locale,
        listener: (context, state) {
          context.setLocale(state.locale);
          if (state.locale.languageCode == 'ar') {
            GoogleFonts.pendingFonts([GoogleFonts.cairo()]);
          }
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            if (context.locale.languageCode != settings.locale.languageCode) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.setLocale(settings.locale);
              });
            }

            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              useInheritedMediaQuery: kIsWeb,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: kIsWeb ? DevicePreview.locale(context) : settings.locale,
              theme: AppTheme.light(locale: settings.locale.languageCode),
              darkTheme: AppTheme.dark(locale: settings.locale.languageCode),
              themeMode: settings.themeMode,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                final appContent = BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
                  builder: (context, status) {
                    final content = MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: false),
                      child: child ?? const SizedBox.shrink(),
                    );
                    return Column(
                      children: [
                        if (status == ConnectivityStatus.offline)
                          const GlobalOfflineBanner(),
                        Expanded(child: content),
                      ],
                    );
                  },
                );

                if (kIsWeb) {
                  return DevicePreview.appBuilder(context, appContent);
                }
                return appContent;
              },
            );
          },
        ),
      ),
    );
  }
}
