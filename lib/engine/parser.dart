import 'ast_node.dart';
import 'calculator_exception.dart';
import 'token.dart';

/// [Parser] دنباله‌ای از [Token] را با روش نزولی بازگشتی (recursive descent)
/// به یک درخت نحوی ([AstNode]) تبدیل می‌کند.
///
/// دستور زبان (از پایین‌ترین به بالاترین اولویت):
/// ```
/// expression := term (('+' | '-') term)*
/// term       := power (('*' | '/' | '%') power)*
/// power      := unary ('^' power)?      // راست‌به‌چپ
/// unary      := ('-' | '+') unary | primary
/// primary    := number | '(' expression ')'
/// ```
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
    AstNode node = _power();
    while (_current.type == TokenType.multiply ||
        _current.type == TokenType.divide ||
        _current.type == TokenType.percent) {
      final TokenType type = _advance().type;
      final BinaryOperator op = switch (type) {
        TokenType.multiply => BinaryOperator.multiply,
        TokenType.divide => BinaryOperator.divide,
        _ => BinaryOperator.modulo,
      };
      node = BinaryNode(node, op, _power());
    }
    return node;
  }

  AstNode _power() {
    final AstNode node = _unary();
    if (_match(TokenType.power)) {
      // راست‌به‌چپ: 2^3^2 == 2^(3^2)
      final AstNode right = _power();
      return BinaryNode(node, BinaryOperator.power, right);
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
    return _primary();
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
