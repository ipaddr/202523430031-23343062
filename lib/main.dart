import 'package:flutter/material.dart';
import 'pages/auth/splash_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'pages/auth/forgot_password_page.dart';
import 'pages/auth/verification_page.dart';
import 'package:betomic/service/auth_layout.dart';
import 'pages/auth/reset_password_page.dart';
import 'pages/main/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:betomic/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async{
   WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('id_ID', null);
  print("Initializing Firebase...");

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully!");
  } catch (e) {
    print("Error initializing Firebase:");
    print(e);
  }

  runApp(const BeTomicApp());
  print("App started!");
}

class BeTomicApp extends StatelessWidget {
  const BeTomicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeTomic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Raleway',
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashPage(),
        '/auth_layout': (_) => const AuthLayout(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/verify': (_) => const VerificationPage(),
        '/reset': (_) => const ResetPasswordPage(),
        '/main' : (_) => const MainPage(),
      },
    );
  }
}
