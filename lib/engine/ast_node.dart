import 'dart:math' as math;

import 'calculator_exception.dart';

/// گرهٔ پایهٔ درخت نحوی (AST) یک عبارت ریاضی.
abstract class AstNode {
  const AstNode();

  double evaluate();
}

/// یک عدد ثابت در درخت.
class NumberNode extends AstNode {
  final double value;
  const NumberNode(this.value);

  @override
  double evaluate() => value;
}

/// عملگرهای دوتایی پشتیبانی‌شده.
enum BinaryOperator { add, subtract, multiply, divide, modulo, power }

/// یک عملیات دوتایی مانند `چپ عملگر راست`.
class BinaryNode extends AstNode {
  final AstNode left;
  final AstNode right;
  final BinaryOperator operator;

  const BinaryNode(this.left, this.operator, this.right);

  @override
  double evaluate() {
    final double l = left.evaluate();
    final double r = right.evaluate();
    switch (operator) {
      case BinaryOperator.add:
        return l + r;
      case BinaryOperator.subtract:
        return l - r;
      case BinaryOperator.multiply:
        return l * r;
      case BinaryOperator.divide:
        if (r == 0) {
          throw const CalculatorException('تقسیم بر صفر ممکن نیست');
        }
        return l / r;
      case BinaryOperator.modulo:
        if (r == 0) {
          throw const CalculatorException('تقسیم بر صفر ممکن نیست');
        }
        return l % r;
      case BinaryOperator.power:
        final double result = math.pow(l, r).toDouble();
        if (result.isNaN) {
          throw const CalculatorException('توان نامعتبر');
        }
        return result;
    }
  }
}

/// عملگر یکتایی (در حال حاضر فقط منفی‌کردن، مثل `-۵`).
class UnaryNode extends AstNode {
  final AstNode operand;
  final bool isNegative;

  const UnaryNode(this.operand, {this.isNegative = true});

  @override
  double evaluate() => isNegative ? -operand.evaluate() : operand.evaluate();
}

/// درصد پسوندی: مقدار عملوند تقسیم بر ۱۰۰ (مثلاً `50%` یعنی ۰٫۵ و
/// `(2+3)%` یعنی ۰٫۰۵).
class PercentNode extends AstNode {
  final AstNode operand;

  const PercentNode(this.operand);

  @override
  double evaluate() => operand.evaluate() / 100;
}
