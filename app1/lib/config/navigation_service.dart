import 'package:flutter/material.dart';
import 'routes.dart';

/// NavigationService - Service untuk mengelola navigasi dengan mudah
///
/// Gunakan navigation service ini untuk navigate ke route tertentu dengan syntax yang consisten
///
/// Contoh penggunaan:
/// ```dart
/// // Push ke route
/// NavigationService.pushNamed(AppRoutes.home);
///
/// // Push replacement
/// NavigationService.pushReplacementNamed(AppRoutes.login);
///
/// // Pop current page
/// NavigationService.pop();
/// ```
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get current context
  static BuildContext? get context => navigatorKey.currentContext;

  /// Get Navigator State
  static NavigatorState? get _navigator => navigatorKey.currentState;

  /// Push named route
  static Future<dynamic>? pushNamed(String routeName, {Object? arguments}) {
    return _navigator?.pushNamed(routeName, arguments: arguments);
  }

  /// Push replacement named route
  static Future<dynamic>? pushReplacementNamed(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator?.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Push and remove until route
  static void pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required bool Function(Route<dynamic>) predicate,
  }) {
    _navigator?.pushNamedAndRemoveUntil(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pop current page
  static void pop<T extends Object?>([T? result]) {
    _navigator?.pop(result);
  }

  /// Pop until home/initial route
  static void popUntilHome() {
    _navigator?.popUntil((route) => route.isFirst);
  }

  /// Check if can pop
  static bool canPop() {
    return _navigator?.canPop() ?? false;
  }

  /// Navigate to home and clear all previous routes
  static Future<dynamic>? goToHomeAndClear(AppRoutes routes) {
    return _navigator?.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
  }

  /// Navigate to login and clear all previous routes
  static Future<dynamic>? goToLoginAndClear() {
    return _navigator?.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (Route<dynamic> route) => false,
    );
  }
}
