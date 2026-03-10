import 'package:flutter_bloc/flutter_bloc.dart';
import 'loading_event.dart';
import 'loading_state.dart';

/// BLoC untuk manage loading state
class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  LoadingBloc() : super(const LoadingInitial()) {
    on<StartLoading>(_onStartLoading);
    on<StopLoading>(_onStopLoading);
    on<ShowLoadingWithMessage>(_onShowLoadingWithMessage);
  }

  /// Handle: Start loading
  Future<void> _onStartLoading(
    StartLoading event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingInProgress(message: event.message));
  }

  /// Handle: Stop loading
  Future<void> _onStopLoading(
    StopLoading event,
    Emitter<LoadingState> emit,
  ) async {
    emit(const LoadingCompleted());
    emit(const LoadingInitial());
  }

  /// Handle: Show loading with custom message
  Future<void> _onShowLoadingWithMessage(
    ShowLoadingWithMessage event,
    Emitter<LoadingState> emit,
  ) async {
    emit(LoadingInProgress(message: event.message));
  }

  /// Helper method untuk start loading
  static void start(context, {String? message}) {
    context.read<LoadingBloc>().add(StartLoading(message: message));
  }

  /// Helper method untuk stop loading
  static void stop(context) {
    context.read<LoadingBloc>().add(const StopLoading());
  }

  /// Helper method untuk show loading with message
  static void showWithMessage(context, String message) {
    context.read<LoadingBloc>().add(ShowLoadingWithMessage(message: message));
  }
}
