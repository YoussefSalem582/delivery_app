/// Tracks the authenticated user id for mock API endpoints.
class MockSessionContext {
  MockSessionContext._();

  static String? currentUserId;

  static void setUserId(String? userId) {
    currentUserId = userId;
  }

  static void clear() {
    currentUserId = null;
  }
}
