class AppConstants {
  static const tripsBox = 'trips_box';
  static const ordersBox = 'orders_box';
  static const userBox = 'user_box';
  static const notificationsBox = 'notifications_box';
  static const pendingSyncBox = 'pending_sync_box';
  static const cacheMetaBox = 'cache_meta_box';
  static const routeCacheBox = 'route_cache_box';

  static const cacheTtl = Duration(minutes: 5);
  static const routeCacheMaxEntries = 50;

  static const themeKey = 'theme_mode';
  static const localeKey = 'app_locale';

  static const workmanagerTaskName = 'delivery_sync_task';
  static const workmanagerUniqueName = 'delivery_periodic_sync';

  static const defaultPickupLat = 30.0444;
  static const defaultPickupLng = 31.2357;
  static const defaultDropoffLat = 30.0626;
  static const defaultDropoffLng = 31.2497;
}
