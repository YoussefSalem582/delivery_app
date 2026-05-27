import 'package:delivery_app/core/utils/constants.dart';

class CacheFreshness {
  CacheFreshness._();

  static bool isFresh(DateTime? lastFetchedAt) {
    if (lastFetchedAt == null) return false;
    return DateTime.now().difference(lastFetchedAt) < AppConstants.cacheTtl;
  }
}
