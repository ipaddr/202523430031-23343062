import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/loading_bloc.dart';
import '../blocs/loading_state.dart';
import 'loading_widgets.dart';

/// Widget untuk handle loading overlay berdasarkan LoadingBloc state
class LoadingListener extends StatelessWidget {
  final Widget child;

  const LoadingListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoadingBloc, LoadingState>(
      builder: (context, state) {
        if (state is LoadingInProgress) {
          return LoadingOverlay(
            isLoading: true,
            message: state.message,
            child: child,
          );
        }
        return child;
      },
    );
  }
}
