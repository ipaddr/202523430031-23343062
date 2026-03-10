import 'package:equatable/equatable.dart';

/// Navigation states
abstract class NavigationState extends Equatable {
  const NavigationState();

  @override
  List<Object?> get props => [];
}

/// Initial state - app baru dibuka
class NavigationInitial extends NavigationState {
  const NavigationInitial();
}

/// State ketika navigate ke route baru
class NavigationChanged extends NavigationState {
  final String routeName;
  final Object? arguments;

  const NavigationChanged({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

/// State ketika pop/back
class NavigationPopped extends NavigationState {
  final Object? result;

  const NavigationPopped({this.result});

  @override
  List<Object?> get props => [result];
}

/// State ketika replace route
class NavigationReplaced extends NavigationState {
  final String routeName;
  final Object? arguments;

  const NavigationReplaced({required this.routeName, this.arguments});

  @override
  List<Object?> get props => [routeName, arguments];
}

/// State ketika pop until route
class NavigationPoppedUntil extends NavigationState {
  final String routeName;

  const NavigationPoppedUntil({required this.routeName});

  @override
  List<Object?> get props => [routeName];
}
