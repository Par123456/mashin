import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/calc_button_data.dart';
import '../theme/app_theme.dart';

/// دکمهٔ گرافیکی و انیمیشنی ماشین‌حساب با افکت فشردن و درخشش نئون.
class CalculatorButton extends StatefulWidget {
  final CalcButtonData data;

  const CalculatorButton({super.key, required this.data});

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  bool _pressed = false;

  Gradient get _gradient {
    switch (widget.data.kind) {
      case CalcButtonKind.digit:
        return const LinearGradient(
          colors: [AppTheme.surface, Color(0xFF232B55)],
        );
      case CalcButtonKind.operatorOp:
        return const LinearGradient(
          colors: [AppTheme.operatorSurface, Color(0xFF3D4499)],
        );
      case CalcButtonKind.function:
        return const LinearGradient(
          colors: [Color(0xFF2E2E45), Color(0xFF3A3A5C)],
        );
      case CalcButtonKind.equals:
        return AppTheme.accentGradient;
    }
  }

  Color get _glowColor {
    switch (widget.data.kind) {
      case CalcButtonKind.equals:
        return AppTheme.neonCyan;
      case CalcButtonKind.operatorOp:
        return AppTheme.neonPurple;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.data.flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.data.onTap();
          },
          child: AnimatedScale(
            scale: _pressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 64,
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _glowColor.withOpacity(_pressed ? 0.6 : 0.25),
                    blurRadius: _pressed ? 20 : 10,
                    spreadRadius: _pressed ? 1 : 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                widget.data.label,
                style: TextStyle(
                  fontSize: widget.data.kind == CalcButtonKind.digit ? 26 : 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
