import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/network/offline_cubit.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/core/theme/theme_cubit.dart';
import 'package:delivery_app/core/utils/nokta_logo_cache.dart';
import 'package:delivery_app/core/utils/talker_setup.dart';
import 'package:delivery_app/core/widgets/nokta_offline_banner.dart';
import 'package:delivery_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    firebaseReady = true;
  } catch (_) {
    // Firebase optional for demo without google-services config.
  }

  await initDependencies();
  await precacheNoktaLogo();

  final savedLocale = sl<LocaleCubit>().state;
  if (savedLocale == 'ar') {
    await GoogleFonts.pendingFonts([GoogleFonts.cairo()]);
  }

  final talker = sl<Talker>();
  Bloc.observer = createTalkerBlocObserver(talker);

  await sl<FcmService>().init(firebaseReady: firebaseReady);
  await sl<SyncService>().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ToastificationWrapper(
        child: const DeliveryApp(),
      ),
    ),
  );
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final savedLocale = sl<LocaleCubit>().state;
    if (context.locale.languageCode != savedLocale) {
      context.setLocale(Locale(savedLocale));
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<NotificationBloc>()),
        BlocProvider.value(value: sl<OfflineCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          final localeCode = context.locale.languageCode;
          return MaterialApp.router(
            // OS task switcher title — avoid .tr() here; delegates may not be loaded yet.
            title: 'Nokta',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: AppTheme.light(locale: localeCode),
            darkTheme: AppTheme.dark(locale: localeCode),
            themeMode: themeMode,
            routerConfig: sl<AppRouter>().config(),
            builder: (context, child) {
              return BlocBuilder<OfflineCubit, bool>(
                builder: (context, isOffline) {
                  return Column(
                    children: [
                      if (isOffline) const NoktaGlobalOfflineBanner(),
                      Expanded(child: child ?? const SizedBox.shrink()),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
