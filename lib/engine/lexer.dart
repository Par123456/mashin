import 'calculator_exception.dart';
import 'token.dart';

/// [Lexer] یک رشتهٔ عبارت ریاضی را به دنباله‌ای از [Token] تبدیل می‌کند.
class Lexer {
  final String source;
  int _pos = 0;

  Lexer(this.source);

  List<Token> tokenize() {
    final List<Token> tokens = <Token>[];

    while (_pos < source.length) {
      final String ch = source[_pos];

      if (ch == ' ' || ch == '\t') {
        _pos++;
        continue;
      }

      if (_isDigit(ch) || ch == '.') {
        tokens.add(_readNumber());
        continue;
      }

      switch (ch) {
        case '+':
          tokens.add(const Token(TokenType.plus, '+'));
          _pos++;
          break;
        case '-':
        case '−':
          tokens.add(const Token(TokenType.minus, '-'));
          _pos++;
          break;
        case '*':
        case '×':
          tokens.add(const Token(TokenType.multiply, '×'));
          _pos++;
          break;
        case '/':
        case '÷':
          tokens.add(const Token(TokenType.divide, '÷'));
          _pos++;
          break;
        case '%':
          tokens.add(const Token(TokenType.percent, '%'));
          _pos++;
          break;
        case '^':
          tokens.add(const Token(TokenType.power, '^'));
          _pos++;
          break;
        case '(':
          tokens.add(const Token(TokenType.leftParen, '('));
          _pos++;
          break;
        case ')':
          tokens.add(const Token(TokenType.rightParen, ')'));
          _pos++;
          break;
        default:
          throw CalculatorException('نویسهٔ غیرمنتظره: "$ch"');
      }
    }

    tokens.add(const Token(TokenType.end, ''));
    return tokens;
  }

  bool _isDigit(String ch) => ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0;

  Token _readNumber() {
    final int start = _pos;
    bool sawDot = false;
    while (_pos < source.length &&
        (_isDigit(source[_pos]) || source[_pos] == '.')) {
      if (source[_pos] == '.') {
        if (sawDot) break;
        sawDot = true;
      }
      _pos++;
    }
    final String text = source.substring(start, _pos);
    final double? value = double.tryParse(text);
    if (value == null) {
      throw CalculatorException('عدد نامعتبر: "$text"');
    }
    return Token(TokenType.number, text, value);
  }
}
