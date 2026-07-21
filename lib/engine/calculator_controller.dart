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
class CalculatorController extends ChangeNotifier {
  String _expression = '';
  String _preview = '0';
  bool _hasError = false;
  bool _justEvaluated = false;
  final List<HistoryEntry> _history = <HistoryEntry>[];

  static const int maxExpressionLength = 60;
  static const int maxHistoryEntries = 100;
  static const String _operators = '+-*/^';

  String get expression => _expression.isEmpty ? '0' : _expression;
  String get preview => _preview;
  bool get hasError => _hasError;
  List<HistoryEntry> get history => List<HistoryEntry>.unmodifiable(_history);

  String get _lastChar =>
      _expression.isEmpty ? '' : _expression[_expression.length - 1];

  bool get _atMaxLength => _expression.length >= maxExpressionLength;

  void inputDigit(String digit) {
    if (_hasError || _justEvaluated) _resetForNewInput();
    if (_atMaxLength) return;
    // بعد از ')' یا '%' ابتدا باید عملگر بیاید (ضرب ضمنی پشتیبانی نمی‌شود).
    if (_lastChar == ')' || _lastChar == '%') return;
    _expression += digit;
    _updatePreview();
  }

  void inputOperator(String operator) {
    if (_hasError) _resetForNewInput();
    _justEvaluated = false;
    if (_expression.isEmpty) {
      if (operator == '-') {
        _expression = '-';
        _updatePreview();
      }
      return;
    }
    // بعد از منفیِ آغازین فقط عدد یا پرانتز معنا دارد.
    if (_expression == '-') return;
    final String last = _lastChar;
    if (_operators.contains(last)) {
      // «2×-3» مجاز است؛ در بقیهٔ حالت‌ها عملگر قبلی جایگزین می‌شود.
      if (operator == '-' && (last == '*' || last == '/' || last == '^')) {
        if (_atMaxLength) return;
        _expression += operator;
      } else {
        _expression =
            _expression.substring(0, _expression.length - 1) + operator;
      }
    } else if (last == '(') {
      if (operator != '-' || _atMaxLength) return;
      _expression += operator;
    } else {
      if (_atMaxLength) return;
      _expression += operator;
    }
    _updatePreview();
  }

  void inputDecimalPoint() {
    if (_hasError || _justEvaluated) _resetForNewInput();
    if (_atMaxLength) return;
    if (_lastNumberSegment().contains('.')) return;
    final String last = _lastChar;
    if (last == ')' || last == '%') return;
    if (_expression.isEmpty || last == '(' || _operators.contains(last)) {
      // به‌جای ساختن عبارت نامعتبری مثل «2+.»، صفرِ پیشرو اضافه می‌شود.
      if (_expression.length + 2 > maxExpressionLength) return;
      _expression += '0.';
    } else {
      _expression += '.';
    }
    _updatePreview();
  }

  void inputParenthesis(String paren) {
    if (_hasError) _resetForNewInput();
    if (paren == '(' && _justEvaluated) _resetForNewInput();
    _justEvaluated = false;
    if (_atMaxLength) return;
    final String last = _lastChar;
    if (paren == '(') {
      // فقط در ابتدای عبارت، بعد از عملگر یا بعد از '(' معنا دارد.
      if (_expression.isNotEmpty &&
          !_operators.contains(last) &&
          last != '(') {
        return;
      }
    } else {
      if (_openParenCount(_expression) <= 0) return;
      if (!RegExp(r'[0-9)%]').hasMatch(last)) return;
    }
    _expression += paren;
    _updatePreview();
  }

  void togglePercent() {
    if (_hasError) _resetForNewInput();
    if (_expression.isEmpty || _atMaxLength) return;
    // درصد پسوندی فقط بعد از عدد، ')' یا '%' معنا دارد.
    if (!RegExp(r'[0-9)%]').hasMatch(_lastChar)) return;
    _justEvaluated = false;
    _expression += '%';
    _updatePreview();
  }

  void backspace() {
    if (_hasError) {
      _resetForNewInput();
      return;
    }
    _justEvaluated = false;
    if (_expression.isEmpty) return;
    _expression = _expression.substring(0, _expression.length - 1);
    _updatePreview();
  }

  void clearAll() {
    _expression = '';
    _preview = '0';
    _hasError = false;
    _justEvaluated = false;
    notifyListeners();
  }

  void toggleSign() {
    if (_hasError) {
      _resetForNewInput();
      return;
    }
    if (_expression.isEmpty) return;
    _justEvaluated = false;
    if (_expression.startsWith('-')) {
      _expression = _expression.substring(1);
    } else {
      if (_atMaxLength) return;
      _expression = '-$_expression';
    }
    _updatePreview();
  }

  void evaluate() {
    if (_expression.isEmpty) return;
    final String candidate = _normalizedForEvaluation(_expression);
    if (candidate.isEmpty) return;
    final double? result = _tryEvaluate(candidate);
    if (result == null) {
      _hasError = true;
      _justEvaluated = false;
      _preview = 'خطا';
      notifyListeners();
      return;
    }
    final String formatted = _formatNumber(result);
    // فشردن دوبارهٔ «=» روی یک نتیجهٔ آماده، تاریخچه را اسپم نمی‌کند.
    if (candidate != formatted) {
      _history.insert(
        0,
        HistoryEntry(expression: candidate, result: formatted),
      );
      if (_history.length > maxHistoryEntries) {
        _history.removeLast();
      }
    }
    _expression = formatted;
    _preview = formatted;
    _hasError = false;
    _justEvaluated = true;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void useHistoryEntry(HistoryEntry entry) {
    _expression = entry.result;
    _hasError = false;
    _justEvaluated = true;
    _updatePreview();
  }

  void _resetForNewInput() {
    _expression = '';
    _preview = '0';
    _hasError = false;
    _justEvaluated = false;
    notifyListeners();
  }

  String _lastNumberSegment() {
    final RegExpMatch? match = RegExp(r'[0-9.]+$').firstMatch(_expression);
    return match?.group(0) ?? '';
  }

  /// عملگرهای ناتمام انتهای عبارت را حذف و پرانتزهای باز را می‌بندد تا
  /// «=» مثل ماشین‌حساب‌های واقعی رفتار کند (مثلاً «(2+3» → «(2+3)»).
  String _normalizedForEvaluation(String source) {
    String result = source;
    while (result.isNotEmpty) {
      final String last = result[result.length - 1];
      if (_operators.contains(last) || last == '(' || last == '.') {
        result = result.substring(0, result.length - 1);
      } else {
        break;
      }
    }
    final int missing = _openParenCount(result);
    if (missing > 0) {
      result += ')' * missing;
    }
    return result;
  }

  static int _openParenCount(String source) {
    int count = 0;
    for (int i = 0; i < source.length; i++) {
      if (source[i] == '(') count++;
      if (source[i] == ')') count--;
    }
    return count;
  }

  void _updatePreview() {
    if (_expression.isEmpty) {
      _preview = '0';
    } else {
      final double? result =
          _tryEvaluate(_normalizedForEvaluation(_expression));
      _preview = result == null ? _expression : _formatNumber(result);
    }
    notifyListeners();
  }

  double? _tryEvaluate(String source) {
    if (source.isEmpty) return null;
    try {
      final tokens = Lexer(source).tokenize();
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

  String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    String text = value.toStringAsFixed(10);
    // برای مقادیر بسیار بزرگ، toStringAsFixed خروجی علمی (مثل 1e+21)
    // برمی‌گرداند که نباید صفرزدایی شود.
    if (text.contains('.') && !text.contains('e') && !text.contains('E')) {
      text = text.replaceAll(RegExp(r'0+$'), '');
      text = text.replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }
}
