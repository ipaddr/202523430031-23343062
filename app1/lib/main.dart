import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'config/app_router.dart';
import 'config/navigation_service.dart';
import 'blocs/navigation_bloc.dart';
import 'blocs/dialog_bloc.dart';
import 'blocs/loading_bloc.dart';
import 'widgets/navigation_listener.dart';
import 'widgets/dialog_listener.dart';
import 'widgets/loading_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => DialogBloc()),
        BlocProvider(create: (_) => LoadingBloc()),
      ],
      child: NavigationListener(
        child: DialogListener(
          child: LoadingListener(
            child: MaterialApp(
              title: 'Firebase Auth App',
              debugShowCheckedModeBanner: false,
              navigatorKey: NavigationService.navigatorKey,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRoutes.appInit,
            ),
          ),
        ),
      ),
    );
  }
}
