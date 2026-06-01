import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// BLoC untuk manage navigation/routing
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationInitial()) {
    on<NavigateTo>(_onNavigateTo);
    on<NavigationPop>(_onNavigationPop);
    on<PopUntil>(_onPopUntil);
    on<PopAndNavigate>(_onPopAndNavigate);
    on<ReplaceRoute>(_onReplaceRoute);
  }

  /// Handle: Navigate ke route baru
  Future<void> _onNavigateTo(
    NavigateTo event,
    Emitter<NavigationState> emit,
  ) async {
    emit(
      NavigationChanged(routeName: event.routeName, arguments: event.arguments),
    );
  }

  /// Handle: Pop/back ke route sebelumnya
  Future<void> _onNavigationPop(
    NavigationPop event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationPopped(result: event.result));
  }

  /// Handle: Pop sampai ke route tertentu
  Future<void> _onPopUntil(
    PopUntil event,
    Emitter<NavigationState> emit,
  ) async {
    emit(NavigationPoppedUntil(routeName: event.routeName));
  }

  /// Handle: Pop all dan navigate ke route baru
  Future<void> _onPopAndNavigate(
    PopAndNavigate event,
    Emitter<NavigationState> emit,
  ) async {
    emit(
      NavigationChanged(routeName: event.routeName, arguments: event.arguments),
    );
  }

  /// Handle: Replace route saat ini dengan route baru
  Future<void> _onReplaceRoute(
    ReplaceRoute event,
    Emitter<NavigationState> emit,
  ) async {
    emit(
      NavigationReplaced(
        routeName: event.routeName,
        arguments: event.arguments,
      ),
    );
  }

  /// Helper method untuk navigate
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.read<NavigationBloc>().add(
      NavigateTo(routeName: routeName, arguments: arguments),
    );
  }

  /// Helper method untuk pop
  static void pop(BuildContext context, {Object? result}) {
    context.read<NavigationBloc>().add(NavigationPop(result: result));
  }

  /// Helper method untuk replace
  static void replace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    context.read<NavigationBloc>().add(
      ReplaceRoute(routeName: routeName, arguments: arguments),
    );
  }

  /// Helper method untuk pop all
  static void popAll(BuildContext context, String routeName) {
    context.read<NavigationBloc>().add(PopUntil(routeName: routeName));
  }
}
