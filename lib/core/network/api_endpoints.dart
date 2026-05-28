import 'package:delivery_app/config/environment/env_config.dart';

class ApiEndpoints {
  static const baseUrl = 'https://mock.nokta.app/api';
  static const trips = '/trips';
  static const orders = '/orders';
  static const profile = '/profile';
  static const drivers = '/drivers';
  static const riders = '/riders';
  static const requestTrip = '/trips/request';

  static String get driverRegister => _driverPath('/register');
  static String get driverProfile => _driverPath('/profile');
  static String get driverAvailability => _driverPath('/availability');
  static String get driverOffers => _driverPath('/offers');

  static String tripById(String id) => '/trips/$id';
  static String tripStatus(String id) => '/trips/$id/status';
  static String driverReviews(String driverId) => '/drivers/$driverId/reviews';
  static String driverOfferAccept(String tripId) =>
      '${_driverPath('/offers')}/$tripId/accept';
  static String driverOfferDecline(String tripId) =>
      '${_driverPath('/offers')}/$tripId/decline';
  static String driverTripStatus(String tripId) =>
      '${_driverPath('/trips')}/$tripId/status';
  static String driverTripLocation(String tripId) =>
      '${_driverPath('/trips')}/$tripId/location';

  static String _driverPath(String suffix) {
    if (EnvConfig.useMockDriverApi) {
      return '/driver$suffix';
    }
    return '/v1/driver$suffix';
  }
}
