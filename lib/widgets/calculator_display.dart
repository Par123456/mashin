import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// نمایشگر بالای ماشین‌حساب: عبارت جاری + پیش‌نمایش نتیجه، با انیمیشن محو‌شدن.
class CalculatorDisplay extends StatelessWidget {
  final String expression;
  final String preview;
  final bool hasError;

  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.preview,
    required this.hasError,
  });

  /// عملگرهای ASCII را برای نمایش زیباتر، به نمادهای یونیکد تبدیل می‌کند.
  String _prettify(String value) {
    return value.replaceAll('*', '×').replaceAll('/', '÷').replaceAll('-', '−');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _prettify(expression),
              key: ValueKey<String>(expression),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _prettify(preview),
              key: ValueKey<String>(preview),
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                foreground: Paint()
                  ..shader = (hasError ? AppTheme.dangerGradient : AppTheme.accentGradient)
                      .createShader(const Rect.fromLTWH(0, 0, 320, 70)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
