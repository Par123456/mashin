import 'package:flutter_test/flutter_test.dart';
import 'package:khatarnak_calculator/engine/calculator_controller.dart';

void main() {
  group('CalculatorController', () {
    test('محاسبهٔ عبارت‌های ساده', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      expect(controller.expression, '5');
    });

    test('رعایت اولویت عملگرها', () {
      final CalculatorController controller = CalculatorController();
      for (final String ch in '2+3*4'.split('')) {
        if ('0123456789'.contains(ch)) {
          controller.inputDigit(ch);
        } else if (ch == '+') {
          controller.inputOperator('+');
        } else if (ch == '*') {
          controller.inputOperator('*');
        }
      }
      controller.evaluate();
      expect(controller.expression, '14');
    });

    test('خطای تقسیم بر صفر', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('5');
      controller.inputOperator('/');
      controller.inputDigit('0');
      controller.evaluate();
      expect(controller.hasError, isTrue);
    });

    test('پرانتز و توان', () {
      final CalculatorController controller = CalculatorController();
      for (final String ch in '(2+3)^2'.split('')) {
        if ('0123456789'.contains(ch)) {
          controller.inputDigit(ch);
        } else if (ch == '(' || ch == ')') {
          controller.inputParenthesis(ch);
        } else if (ch == '+') {
          controller.inputOperator('+');
        } else if (ch == '^') {
          controller.inputOperator('^');
        }
      }
      controller.evaluate();
      expect(controller.expression, '25');
    });

    test('درصد', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('5');
      controller.inputDigit('0');
      controller.togglePercent();
      controller.evaluate();
      expect(controller.expression, '0.5');
    });
  });
}
