import 'ast_node.dart';
import 'calculator_exception.dart';
import 'token.dart';

/// [Parser] دنباله‌ای از [Token] را با روش نزولی بازگشتی (recursive descent)
/// به یک درخت نحوی ([AstNode]) تبدیل می‌کند.
///
/// دستور زبان (از اولویت کم به زیاد):
/// ```
/// expression → term (('+' | '-') term)*
/// term       → unary (('×' | '÷') unary)*
/// unary      → ('-' | '+') unary | power
/// power      → postfix ('^' unary)?      // راست‌به‌چپ: 2^3^2 == 2^(3^2)
/// postfix    → primary ('%')*            // درصد پسوندی: 50% == 0.5
/// primary    → number | '(' expression ')'
/// ```
///
/// نکته: منفی یکانی اولویتی پایین‌تر از توان دارد تا مطابق قرارداد ریاضی،
/// `-2^2` برابر `-(2^2) = -4` باشد (و نه `(-2)^2 = 4`).
class Parser {
  final List<Token> tokens;
  int _pos = 0;

  Parser(this.tokens);

  AstNode parse() {
    final AstNode node = _expression();
    if (_current.type != TokenType.end) {
      throw CalculatorException('نویسهٔ اضافی در عبارت: "${_current.text}"');
    }
    return node;
  }

  Token get _current => tokens[_pos];

  Token _advance() => tokens[_pos++];

  bool _match(TokenType type) {
    if (_current.type == type) {
      _advance();
      return true;
    }
    return false;
  }

  AstNode _expression() {
    AstNode node = _term();
    while (_current.type == TokenType.plus || _current.type == TokenType.minus) {
      final BinaryOperator op = _advance().type == TokenType.plus
          ? BinaryOperator.add
          : BinaryOperator.subtract;
      node = BinaryNode(node, op, _term());
    }
    return node;
  }

  AstNode _term() {
    AstNode node = _unary();
    while (_current.type == TokenType.multiply ||
        _current.type == TokenType.divide) {
      final BinaryOperator op = _advance().type == TokenType.multiply
          ? BinaryOperator.multiply
          : BinaryOperator.divide;
      node = BinaryNode(node, op, _unary());
    }
    return node;
  }

  AstNode _unary() {
    if (_match(TokenType.minus)) {
      return UnaryNode(_unary(), isNegative: true);
    }
    if (_match(TokenType.plus)) {
      return _unary();
    }
    return _power();
  }

  AstNode _power() {
    final AstNode node = _postfix();
    if (_match(TokenType.power)) {
      // راست‌به‌چپ: 2^3^2 == 2^(3^2)؛ توان می‌تواند علامت‌دار باشد: 2^-3
      return BinaryNode(node, BinaryOperator.power, _unary());
    }
    return node;
  }

  AstNode _postfix() {
    AstNode node = _primary();
    while (_match(TokenType.percent)) {
      node = PercentNode(node);
    }
    return node;
  }

  AstNode _primary() {
    final Token token = _current;
    if (token.type == TokenType.number) {
      _advance();
      return NumberNode(token.value!);
    }
    if (token.type == TokenType.leftParen) {
      _advance();
      final AstNode node = _expression();
      if (!_match(TokenType.rightParen)) {
        throw const CalculatorException('پرانتز بسته وجود ندارد');
      }
      return node;
    }
    throw CalculatorException('عبارت نامعتبر نزدیک "${token.text}"');
  }
}
