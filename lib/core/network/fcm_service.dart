import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:delivery_app/core/architecture/entities/notification_entity.dart';
import 'package:delivery_app/core/architecture/repositories/notification_repository.dart';

typedef NotificationHandler = void Function(NotificationEntity notification);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background handler — Firebase must be initialized in main isolate first.
}

class FcmService {
  FcmService({
    required NotificationRepository notificationRepository,
    required Talker talker,
  })  : _notificationRepository = notificationRepository,
        _talker = talker;

  final NotificationRepository _notificationRepository;
  final Talker _talker;
  final _uuid = const Uuid();

  NotificationHandler? onNotification;

  Future<void> init() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedApp);
      await messaging.subscribeToTopic('trip_updates');
      _talker.info('[FCM] Initialized and subscribed to trip_updates');
    } catch (e, st) {
      _talker.handle(e, st, '[FCM] Init failed — using simulated notifications');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = NotificationEntity(
      id: message.messageId ?? _uuid.v4(),
      title: message.notification?.title ?? 'Trip Update',
      body: message.notification?.body ?? '',
      createdAt: DateTime.now(),
      tripId: message.data['tripId'] as String?,
    );
    await _saveAndEmit(notification);
  }

  Future<void> _handleOpenedApp(RemoteMessage message) async {
    await _handleForegroundMessage(message);
  }

  Future<void> simulateTripNotification({
    required String title,
    required String body,
    String? tripId,
  }) async {
    final notification = NotificationEntity(
      id: _uuid.v4(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      tripId: tripId,
    );
    await _saveAndEmit(notification);
    _talker.info('[FCM] Simulated notification: $title');
  }

  Future<void> _saveAndEmit(NotificationEntity notification) async {
    await _notificationRepository.addNotification(notification);
    onNotification?.call(notification);
  }
}
