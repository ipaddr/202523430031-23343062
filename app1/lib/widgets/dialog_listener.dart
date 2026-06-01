import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dialog_bloc.dart';
import '../blocs/dialog_event.dart';
import '../blocs/dialog_state.dart';

/// Widget untuk menampilkan dialog berdasarkan DialogBloc state
class DialogListener extends StatelessWidget {
  final Widget child;

  const DialogListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DialogBloc, DialogState>(
      listener: (context, state) {
        if (state is ConfirmationDialogState) {
          _showConfirmationDialog(context, state);
        } else if (state is SuccessDialogState) {
          _showSuccessDialog(context, state);
        } else if (state is ErrorDialogState) {
          _showErrorDialog(context, state);
        } else if (state is InfoDialogState) {
          _showInfoDialog(context, state);
        } else if (state is DialogClosed) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      },
      child: child,
    );
  }

  /// Show confirmation dialog
  void _showConfirmationDialog(
    BuildContext context,
    ConfirmationDialogState state,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.title),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DialogBloc>().add(const OnDialogCancelled());
            },
            child: Text(state.cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DialogBloc>().add(const OnDialogConfirmed());
            },
            child: Text(state.confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, SuccessDialogState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.title),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DialogBloc>().add(const CloseDialog());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, ErrorDialogState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.title),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DialogBloc>().add(const CloseDialog());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show info dialog
  void _showInfoDialog(BuildContext context, InfoDialogState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.title),
        content: Text(state.message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DialogBloc>().add(const CloseDialog());
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
