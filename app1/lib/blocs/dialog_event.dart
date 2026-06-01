import 'package:equatable/equatable.dart';

/// Dialog events
abstract class DialogEvent extends Equatable {
  const DialogEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk show confirmation dialog
class ShowConfirmationDialog extends DialogEvent {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  const ShowConfirmationDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Ya',
    this.cancelLabel = 'Batal',
  });

  @override
  List<Object?> get props => [title, message, confirmLabel, cancelLabel];
}

/// Event untuk show success dialog
class ShowSuccessDialog extends DialogEvent {
  final String title;
  final String message;

  const ShowSuccessDialog({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// Event untuk show error dialog
class ShowErrorDialog extends DialogEvent {
  final String title;
  final String message;

  const ShowErrorDialog({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// Event untuk show info dialog
class ShowInfoDialog extends DialogEvent {
  final String title;
  final String message;

  const ShowInfoDialog({required this.title, required this.message});

  @override
  List<Object?> get props => [title, message];
}

/// Event untuk close dialog
class CloseDialog extends DialogEvent {
  const CloseDialog();
}

/// Event ketika user confirm
class OnDialogConfirmed extends DialogEvent {
  const OnDialogConfirmed();
}

/// Event ketika user cancel
class OnDialogCancelled extends DialogEvent {
  const OnDialogCancelled();
}
