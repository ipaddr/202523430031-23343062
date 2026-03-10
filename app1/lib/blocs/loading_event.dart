import 'package:equatable/equatable.dart';

/// Loading events
abstract class LoadingEvent extends Equatable {
  const LoadingEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk start loading
class StartLoading extends LoadingEvent {
  final String? message;

  const StartLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Event untuk stop loading
class StopLoading extends LoadingEvent {
  const StopLoading();
}

/// Event untuk show loading dengan pesan custom
class ShowLoadingWithMessage extends LoadingEvent {
  final String message;

  const ShowLoadingWithMessage({required this.message});

  @override
  List<Object?> get props => [message];
}
