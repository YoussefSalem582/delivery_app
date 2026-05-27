class ApiEndpoints {
  static const baseUrl = 'https://mock.nokta.app/api';
  static const trips = '/trips';
  static const orders = '/orders';
  static const profile = '/profile';
  static const drivers = '/drivers';

  static String tripById(String id) => '/trips/$id';
  static String tripStatus(String id) => '/trips/$id/status';
  static String driverReviews(String driverId) => '/drivers/$driverId/reviews';
  static const requestTrip = '/trips/request';
}
