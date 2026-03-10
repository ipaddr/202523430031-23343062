import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/navigation_bloc.dart';
import '../blocs/navigation_state.dart';

/// Widget untuk handle navigation berdasarkan NavigationBloc state
class NavigationListener extends StatelessWidget {
  final Widget child;

  const NavigationListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listener: (context, state) {
        if (state is NavigationChanged) {
          _navigateTo(context, state);
        } else if (state is NavigationPopped) {
          _pop(context, state);
        } else if (state is NavigationReplaced) {
          _replace(context, state);
        } else if (state is NavigationPoppedUntil) {
          _popUntil(context, state);
        }
      },
      child: child,
    );
  }

  /// Handle navigate to route
  void _navigateTo(BuildContext context, NavigationChanged state) {
    Navigator.pushNamed(context, state.routeName, arguments: state.arguments);
  }

  /// Handle pop
  void _pop(BuildContext context, NavigationPopped state) {
    Navigator.pop(context, state.result);
  }

  /// Handle replace route
  void _replace(BuildContext context, NavigationReplaced state) {
    Navigator.pushReplacementNamed(
      context,
      state.routeName,
      arguments: state.arguments,
    );
  }

  /// Handle pop until route
  void _popUntil(BuildContext context, NavigationPoppedUntil state) {
    Navigator.popUntil(context, ModalRoute.withName(state.routeName));
  }
}
