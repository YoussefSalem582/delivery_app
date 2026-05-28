import 'package:delivery_app/app.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/core/sync/sync_service.dart';
import 'package:delivery_app/core/utils/app_logo_cache.dart';
import 'package:delivery_app/core/utils/talker_setup.dart';
import 'package:delivery_app/injection_container.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  await precacheAppLogo();

  final talker = sl<Talker>();
  Bloc.observer = createTalkerBlocObserver(talker);

  await sl<FcmService>().init(firebaseReady: firebaseReady);
  await sl<SyncService>().init();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: ToastificationWrapper(
          child: const NoktaApp(),
        ),
      ),
    ),
  );
}
