import 'package:betomic/pages/auth/login_page.dart';
import 'package:betomic/pages/main/main_page.dart';
import 'package:betomic/service/auth.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});
  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.hasData) {
              widget = const MainPage();
            } else {
              widget = pageIfNotConnected ?? const LoginPage();
            }

            return widget;
          },
        );
      },
    );
  }
}
