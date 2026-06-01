import 'package:equatable/equatable.dart';

/// Loading states
abstract class LoadingState extends Equatable {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

/// Initial state - tidak ada loading
class LoadingInitial extends LoadingState {
  const LoadingInitial();
}

/// State ketika loading
class LoadingInProgress extends LoadingState {
  final String? message;

  const LoadingInProgress({this.message});

  @override
  List<Object?> get props => [message];
}

/// State ketika loading selesai
class LoadingCompleted extends LoadingState {
  const LoadingCompleted();
}
