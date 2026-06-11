import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'utils/app_theme.dart';
import 'views/auth/landing_screen.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: LandingScreen(authController: AuthController()),
    );
  }
}
