// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // after 2s, go to HomePage
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final logoPath = brightness == Brightness.dark
        ? 'lib/assets/images/Logo_Uccelli_Quer_Negativ.png'
        : 'lib/assets/images/Logo_Uccelli_Quer_Positiv.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Image.asset(logoPath, width: 180),
      ),
    );
  }
}
