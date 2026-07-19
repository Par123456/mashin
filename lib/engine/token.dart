/// انواع توکن‌های قابل تشخیص توسط [Lexer].
enum TokenType {
  number,
  plus,
  minus,
  multiply,
  divide,
  percent,
  power,
  leftParen,
  rightParen,
  end,
}

/// یک توکن: کوچک‌ترین واحد معنادار در یک عبارت ریاضی.
class Token {
  final TokenType type;
  final String text;
  final double? value;

  const Token(this.type, this.text, [this.value]);

  @override
  String toString() => 'Token(${type.name}, "$text")';
}
