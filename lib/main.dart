import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'utils/app_theme.dart';
import 'utils/theme_manager.dart';
import 'views/auth/landing_screen.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Harder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeManager.instance.themeMode,
          home: LandingScreen(authController: AuthController()),
        );
      },
    );
  }
}
