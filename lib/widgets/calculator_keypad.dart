import 'package:flutter/material.dart';

import '../models/calc_button_data.dart';
import 'calculator_button.dart';

/// چیدمان شبکه‌ای دکمه‌های ماشین‌حساب بر اساس ردیف‌های داده‌شده.
class CalculatorKeypad extends StatelessWidget {
  final List<List<CalcButtonData>> rows;

  const CalculatorKeypad({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final data in row) CalculatorButton(data: data),
            ],
          ),
      ],
    );
  }
}
