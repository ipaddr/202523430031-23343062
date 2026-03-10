import 'package:flutter_bloc/flutter_bloc.dart';
import 'dialog_event.dart';
import 'dialog_state.dart';

/// BLoC untuk manage dialogs
class DialogBloc extends Bloc<DialogEvent, DialogState> {
  DialogBloc() : super(const DialogInitial()) {
    on<ShowConfirmationDialog>(_onShowConfirmationDialog);
    on<ShowSuccessDialog>(_onShowSuccessDialog);
    on<ShowErrorDialog>(_onShowErrorDialog);
    on<ShowInfoDialog>(_onShowInfoDialog);
    on<CloseDialog>(_onCloseDialog);
    on<OnDialogConfirmed>(_onDialogConfirmed);
    on<OnDialogCancelled>(_onDialogCancelled);
  }

  /// Handle: Tampilkan confirmation dialog
  Future<void> _onShowConfirmationDialog(
    ShowConfirmationDialog event,
    Emitter<DialogState> emit,
  ) async {
    emit(
      ConfirmationDialogState(
        title: event.title,
        message: event.message,
        confirmLabel: event.confirmLabel,
        cancelLabel: event.cancelLabel,
      ),
    );
  }

  /// Handle: Tampilkan success dialog
  Future<void> _onShowSuccessDialog(
    ShowSuccessDialog event,
    Emitter<DialogState> emit,
  ) async {
    emit(SuccessDialogState(title: event.title, message: event.message));
  }

  /// Handle: Tampilkan error dialog
  Future<void> _onShowErrorDialog(
    ShowErrorDialog event,
    Emitter<DialogState> emit,
  ) async {
    emit(ErrorDialogState(title: event.title, message: event.message));
  }

  /// Handle: Tampilkan info dialog
  Future<void> _onShowInfoDialog(
    ShowInfoDialog event,
    Emitter<DialogState> emit,
  ) async {
    emit(InfoDialogState(title: event.title, message: event.message));
  }

  /// Handle: Close dialog
  Future<void> _onCloseDialog(
    CloseDialog event,
    Emitter<DialogState> emit,
  ) async {
    emit(const DialogClosed());
  }

  /// Handle: Dialog confirmed
  Future<void> _onDialogConfirmed(
    OnDialogConfirmed event,
    Emitter<DialogState> emit,
  ) async {
    emit(const DialogConfirmed());
  }

  /// Handle: Dialog cancelled
  Future<void> _onDialogCancelled(
    OnDialogCancelled event,
    Emitter<DialogState> emit,
  ) async {
    emit(const DialogCancelled());
  }
}
