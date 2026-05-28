enum NotificationType {
  tripUpdate,
  driverOnTheWay,
  driverArrived,
  tripAccepted,
  tripCompleted,
  promo,
  general;

  String toJsonKey() {
    return switch (this) {
      NotificationType.tripUpdate => 'tripUpdate',
      NotificationType.driverOnTheWay => 'driverOnTheWay',
      NotificationType.driverArrived => 'driverArrived',
      NotificationType.tripAccepted => 'tripAccepted',
      NotificationType.tripCompleted => 'tripCompleted',
      NotificationType.promo => 'promo',
      NotificationType.general => 'general',
    };
  }

  static NotificationType fromJsonKey(String? value) {
    return switch (value) {
      'tripUpdate' => NotificationType.tripUpdate,
      'driverOnTheWay' => NotificationType.driverOnTheWay,
      'driverArrived' => NotificationType.driverArrived,
      'tripAccepted' => NotificationType.tripAccepted,
      'tripCompleted' => NotificationType.tripCompleted,
      'promo' => NotificationType.promo,
      _ => NotificationType.general,
    };
  }

  /// Infers type from legacy i18n title keys when Hive rows lack [type].
  static NotificationType inferFromTitleKey(String title) {
    if (title.contains('driver_on_the_way') || title.contains('heading_pickup')) {
      return NotificationType.driverOnTheWay;
    }
    if (title.contains('driver_arrived')) {
      return NotificationType.driverArrived;
    }
    if (title.contains('trip_accepted')) {
      return NotificationType.tripAccepted;
    }
    if (title.contains('trip_completed') || title.contains('thanks_riding')) {
      return NotificationType.tripCompleted;
    }
    if (title.contains('trip_update')) {
      return NotificationType.tripUpdate;
    }
    if (title.contains('promo')) {
      return NotificationType.promo;
    }
    return NotificationType.general;
  }
}
