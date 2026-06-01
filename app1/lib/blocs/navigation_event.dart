import 'package:equatable/equatable.dart';

/// Navigation events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk navigate ke route
class NavigateTo extends NavigationEvent {
  final String routeName;
  final Object? arguments;

  const NavigateTo({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

/// Event untuk pop/back
class NavigationPop extends NavigationEvent {
  final Object? result;

  const NavigationPop({this.result});

  @override
  List<Object?> get props => [result];
}

/// Event untuk pop sampai route
class PopUntil extends NavigationEvent {
  final String routeName;

  const PopUntil({required this.routeName});

  @override
  List<Object?> get props => [routeName];
}

/// Event untuk pop all dan navigate
class PopAndNavigate extends NavigationEvent {
  final String routeName;
  final Object? arguments;

  const PopAndNavigate({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

/// Event untuk replace route
class ReplaceRoute extends NavigationEvent {
  final String routeName;
  final Object? arguments;

  const ReplaceRoute({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}
