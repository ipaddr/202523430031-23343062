import 'package:flutter/material.dart';
import '../../theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/auth_layout');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", width: 120),
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: [primaryColor, secondaryColor],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                "BeTomic",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
