import 'package:equatable/equatable.dart';
import 'dialog_event.dart';

/// Dialog states
abstract class DialogState extends Equatable {
  const DialogState();

  @override
  List<Object?> get props => [];
}

/// Initial state - tidak ada dialog
class DialogInitial extends DialogState {
  const DialogInitial();
}

/// State ketika confirmation dialog ditampilkan
class ConfirmationDialogState extends DialogState {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const ConfirmationDialogState({
    required this.title,
    required this.message,
    this.confirmLabel = 'Ya',
    this.cancelLabel = 'Batal',
  });

  @override
  List<Object?> get props => [title, message, confirmLabel, cancelLabel];
}

/// State ketika success dialog ditampilkan
class SuccessDialogState extends DialogState {
  final String title;
  final String message;

  const SuccessDialogState({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// State ketika error dialog ditampilkan
class ErrorDialogState extends DialogState {
  final String title;
  final String message;

  const ErrorDialogState({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// State ketika info dialog ditampilkan
class InfoDialogState extends DialogState {
  final String title;
  final String message;

  const InfoDialogState({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// State ketika user confirm
class DialogConfirmed extends DialogState {
  const DialogConfirmed();
}

/// State ketika user cancel
class DialogCancelled extends DialogState {
  const DialogCancelled();
}

/// State ketika dialog di-close
class DialogClosed extends DialogState {
  const DialogClosed();
}
