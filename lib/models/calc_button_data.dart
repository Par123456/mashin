import 'package:flutter/material.dart';

/// دسته‌بندی دکمه‌های ماشین‌حساب برای تعیین رنگ و رفتار آن‌ها.
enum CalcButtonKind { digit, operatorOp, function, equals }

/// داده‌های نمایشی و رفتاری یک دکمه.
@immutable
class CalcButtonData {
  final String label;
  final CalcButtonKind kind;
  final VoidCallback onTap;
  final int flex;

  const CalcButtonData({
    required this.label,
    required this.kind,
    required this.onTap,
    this.flex = 1,
  });
}
