import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'theme/app_theme.dart';

/// ریشهٔ اپلیکیشن ماشین‌حساب خطرناک.
class KhatarnakCalculatorApp extends StatelessWidget {
  const KhatarnakCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ماشین‌حساب خطرناک',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkNeonTheme,
      home: const CalculatorScreen(),
    );
  }
}
