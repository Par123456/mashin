import 'package:flutter/material.dart';

import '../engine/calculator_controller.dart';
import '../models/calc_button_data.dart';
import '../theme/app_theme.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/history_panel.dart';

/// صفحهٔ اصلی ماشین‌حساب: نمایشگر + صفحه‌کلید + دسترسی به تاریخچه.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController _controller = CalculatorController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  void _openHistory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return HistoryPanel(
          entries: _controller.history,
          onSelect: (entry) {
            _controller.useHistoryEntry(entry);
            Navigator.of(context).pop();
          },
          onClear: _controller.clearHistory,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  List<List<CalcButtonData>> _buildRows() {
    return [
      [
        CalcButtonData(label: 'AC', kind: CalcButtonKind.function, onTap: _controller.clearAll),
        CalcButtonData(label: '(', kind: CalcButtonKind.function, onTap: () => _controller.inputParenthesis('(')),
        CalcButtonData(label: ')', kind: CalcButtonKind.function, onTap: () => _controller.inputParenthesis(')')),
        CalcButtonData(label: '%', kind: CalcButtonKind.function, onTap: _controller.togglePercent),
      ],
      [
        CalcButtonData(label: '7', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('7')),
        CalcButtonData(label: '8', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('8')),
        CalcButtonData(label: '9', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('9')),
        CalcButtonData(label: '÷', kind: CalcButtonKind.operatorOp, onTap: () => _controller.inputOperator('/')),
      ],
      [
        CalcButtonData(label: '4', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('4')),
        CalcButtonData(label: '5', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('5')),
        CalcButtonData(label: '6', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('6')),
        CalcButtonData(label: '×', kind: CalcButtonKind.operatorOp, onTap: () => _controller.inputOperator('*')),
      ],
      [
        CalcButtonData(label: '1', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('1')),
        CalcButtonData(label: '2', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('2')),
        CalcButtonData(label: '3', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('3')),
        CalcButtonData(label: '−', kind: CalcButtonKind.operatorOp, onTap: () => _controller.inputOperator('-')),
      ],
      [
        CalcButtonData(label: '±', kind: CalcButtonKind.function, onTap: _controller.toggleSign),
        CalcButtonData(label: '0', kind: CalcButtonKind.digit, onTap: () => _controller.inputDigit('0')),
        CalcButtonData(label: '.', kind: CalcButtonKind.digit, onTap: _controller.inputDecimalPoint),
        CalcButtonData(label: '+', kind: CalcButtonKind.operatorOp, onTap: () => _controller.inputOperator('+')),
      ],
      [
        CalcButtonData(label: '^', kind: CalcButtonKind.operatorOp, onTap: () => _controller.inputOperator('^')),
        CalcButtonData(label: '⌫', kind: CalcButtonKind.function, onTap: _controller.backspace),
        CalcButtonData(label: '=', kind: CalcButtonKind.equals, onTap: _controller.evaluate, flex: 2),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: IconButton(
                    onPressed: _openHistory,
                    icon: const Icon(Icons.history, color: Colors.white70),
                  ),
                ),
              ),
              Expanded(
                child: CalculatorDisplay(
                  expression: _controller.expression,
                  preview: _controller.preview,
                  hasError: _controller.hasError,
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    child: CalculatorKeypad(rows: _buildRows()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
