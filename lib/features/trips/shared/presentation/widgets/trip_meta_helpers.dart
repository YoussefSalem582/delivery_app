import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:easy_localization/easy_localization.dart';

String formatTripDistanceKm(double? distanceKm) {
  if (distanceKm == null || distanceKm <= 0) return '';
  return 'trip_distance_km'.tr(namedArgs: {'distance': distanceKm.toStringAsFixed(1)});
}

String formatTripEtaMinutes(int? etaMinutes) {
  if (etaMinutes == null || etaMinutes <= 0) return '';
  return '$etaMinutes ${'minutes'.tr()}';
}

String formatTripPaymentLabel(String? paymentMethodKey) {
  if (paymentMethodKey == null || paymentMethodKey.isEmpty) return '';
  return paymentMethodKey.tr();
}

String formatTripRideTierLabel(String? rideTierKey) {
  if (rideTierKey == null || rideTierKey.isEmpty) return '';
  return rideTierKey.tr();
}

List<String> tripMetaLabels(TripEntity trip) {
  final labels = <String>[];
  final distance = formatTripDistanceKm(trip.distanceKm);
  if (distance.isNotEmpty) labels.add(distance);

  final eta = formatTripEtaMinutes(trip.etaMinutes);
  if (eta.isNotEmpty) labels.add(eta);

  final tier = formatTripRideTierLabel(trip.rideTierKey);
  if (tier.isNotEmpty) labels.add(tier);

  final payment = formatTripPaymentLabel(trip.paymentMethodKey);
  if (payment.isNotEmpty) labels.add(payment);

  return labels;
}
