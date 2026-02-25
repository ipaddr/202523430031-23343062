/// Route name constants untuk aplikasi
/// Gunakan constants ini untuk navigasi menggunakan named routes
class AppRoutes {
  // Splashscreen dan Initialization Routes
  static const String splash = '/splash';
  static const String appInit = '/init';

  // Authentication Routes
  static const String login = '/login';
  static const String registration = '/registration';
  static const String emailVerification = '/email-verification';

  // Main App Routes
  static const String home = '/home';
  static const String notes = '/notes';
  static const String logout = '/logout';

  // Utility Routes
  static const String error = '/error';

  /// Get all route names (for debugging)
  static List<String> getAllRoutes() {
    return [
      splash,
      appInit,
      login,
      registration,
      emailVerification,
      home,
      notes,
      logout,
      error,
    ];
  }
}
