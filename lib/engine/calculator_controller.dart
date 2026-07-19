import 'package:flutter/foundation.dart';

import 'calculator_exception.dart';
import 'lexer.dart';
import 'parser.dart';

/// یک محاسبهٔ ثبت‌شده در تاریخچه.
class HistoryEntry {
  final String expression;
  final String result;
  final DateTime time;

  HistoryEntry({
    required this.expression,
    required this.result,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

/// مغز ماشین‌حساب: نگه‌داری وضعیت عبارت جاری، اجرای محاسبه (از طریق
/// Lexer → Parser → AST) و مدیریت تاریخچه.
///
/// این کلاس از الگوی MVC پیروی می‌کند؛ رابط کاربری فقط به این شیء
/// (به‌عنوان ChangeNotifier) گوش می‌دهد و هیچ منطق محاسباتی در ویجت‌ها
/// وجود ندارد.
class CalculatorController extends ChangeNotifier {
  String _expression = '';
  String _preview = '0';
  bool _hasError = false;
  final List<HistoryEntry> _history = <HistoryEntry>[];

  static const int maxExpressionLength = 60;

  String get expression => _expression.isEmpty ? '0' : _expression;
  String get preview => _preview;
  bool get hasError => _hasError;
  List<HistoryEntry> get history => List<HistoryEntry>.unmodifiable(_history);

  void inputDigit(String digit) {
    if (_hasError) _resetForNewInput();
    if (_expression.length >= maxExpressionLength) return;
    _expression += digit;
    _updatePreview();
  }

  void inputOperator(String operator) {
    if (_hasError) _resetForNewInput();
    if (_expression.isEmpty && operator != '-') return;
    _expression += operator;
    _updatePreview();
  }

  void inputDecimalPoint() {
    if (_hasError) _resetForNewInput();
    if (_lastNumberSegment().contains('.')) return;
    _expression += _expression.isEmpty ? '0.' : '.';
    _updatePreview();
  }

  void inputParenthesis(String paren) {
    if (_hasError) _resetForNewInput();
    _expression += paren;
    _updatePreview();
  }

  void togglePercent() {
    if (_hasError) _resetForNewInput();
    if (_expression.isEmpty) return;
    _expression += '%';
    _updatePreview();
  }

  void backspace() {
    if (_hasError) {
      _resetForNewInput();
      _updatePreview();
      return;
    }
    if (_expression.isEmpty) return;
    _expression = _expression.substring(0, _expression.length - 1);
    _updatePreview();
  }

  void clearAll() {
    _expression = '';
    _preview = '0';
    _hasError = false;
    notifyListeners();
  }

  void toggleSign() {
    if (_expression.isEmpty) return;
    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      _expression = '-$_expression';
    }
    _updatePreview();
  }

  /// عبارت جاری را محاسبه می‌کند، در صورت موفقیت به تاریخچه اضافه کرده و
  /// نتیجه را جایگزین عبارت جاری می‌کند.
  void evaluate() {
    if (_expression.isEmpty) return;
    final double? result = _tryEvaluate(_expression);
    if (result == null) {
      _hasError = true;
      _preview = 'خطا';
      notifyListeners();
      return;
    }
    final String formatted = _formatNumber(result);
    _history.insert(
      0,
      HistoryEntry(expression: _expression, result: formatted),
    );
    _expression = formatted;
    _preview = formatted;
    _hasError = false;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void useHistoryEntry(HistoryEntry entry) {
    _expression = entry.result;
    _hasError = false;
    _updatePreview();
  }

  void _resetForNewInput() {
    _expression = '';
    _hasError = false;
  }

  String _lastNumberSegment() {
    final RegExpMatch? match = RegExp(r'[0-9.]+$').firstMatch(_expression);
    return match?.group(0) ?? '';
  }

  void _updatePreview() {
    if (_expression.isEmpty) {
      _preview = '0';
    } else {
      final double? result = _tryEvaluate(_expression);
      _preview = result == null ? _expression : _formatNumber(result);
    }
    notifyListeners();
  }

  double? _tryEvaluate(String source) {
    try {
      final String withPercent = _expandPercent(source);
      final tokens = Lexer(withPercent).tokenize();
      final ast = Parser(tokens).parse();
      final double value = ast.evaluate();
      if (value.isNaN || value.isInfinite) return null;
      return value;
    } on CalculatorException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// «۵۰%» را پیش از تحلیل به «(۵۰/۱۰۰)» تبدیل می‌کند تا موتور اصلی
  /// (Lexer/Parser) هیچ دانشی از مفهوم درصد نداشته باشد.
  String _expandPercent(String source) {
    final StringBuffer buffer = StringBuffer();
    final StringBuffer numberBuffer = StringBuffer();

    void flushNumber() {
      if (numberBuffer.isNotEmpty) {
        buffer.write(numberBuffer.toString());
        numberBuffer.clear();
      }
    }

    for (int i = 0; i < source.length; i++) {
      final String ch = source[i];
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        numberBuffer.write(ch);
        continue;
      }
      if (ch == '%') {
        if (numberBuffer.isNotEmpty) {
          buffer.write('(${numberBuffer.toString()}/100)');
          numberBuffer.clear();
        } else {
          buffer.write('%');
        }
        continue;
      }
      flushNumber();
      buffer.write(ch);
    }
    flushNumber();
    return buffer.toString();
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String text = value.toStringAsFixed(10);
    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');
    return text;
  }
}
