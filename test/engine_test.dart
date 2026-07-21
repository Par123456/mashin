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

    test('درصد بعد از پرانتز', () {
      final CalculatorController controller = CalculatorController();
      controller.inputParenthesis('(');
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.inputParenthesis(')');
      controller.togglePercent();
      controller.evaluate();
      expect(controller.hasError, isFalse);
      expect(controller.expression, '0.05');
    });

    test('درصد در دل عبارت (200×10% == 20)', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputDigit('0');
      controller.inputDigit('0');
      controller.inputOperator('*');
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.togglePercent();
      controller.evaluate();
      expect(controller.expression, '20');
    });

    test('اولویت منفی یکانی و توان (-2^2 == -4)', () {
      final CalculatorController controller = CalculatorController();
      controller.inputOperator('-');
      controller.inputDigit('2');
      controller.inputOperator('^');
      controller.inputDigit('2');
      controller.evaluate();
      expect(controller.expression, '-4');
    });

    test('توان با نمای منفی (2^-2 == 0.25)', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('^');
      controller.inputOperator('-');
      controller.inputDigit('2');
      controller.evaluate();
      expect(controller.expression, '0.25');
    });

    test('جایگزینی عملگر تکراری به‌جای خطا', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputOperator('*');
      controller.inputDigit('3');
      controller.evaluate();
      expect(controller.expression, '6');
    });

    test('نقطهٔ اعشار بعد از عملگر صفرِ پیشرو می‌گیرد', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDecimalPoint();
      controller.inputDigit('5');
      controller.evaluate();
      expect(controller.expression, '2.5');
    });

    test('بستن خودکار پرانتزهای باز هنگام =', () {
      final CalculatorController controller = CalculatorController();
      controller.inputParenthesis('(');
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      expect(controller.hasError, isFalse);
      expect(controller.expression, '5');
    });

    test('پرانتز بستهٔ بی‌جفت پذیرفته نمی‌شود', () {
      final CalculatorController controller = CalculatorController();
      controller.inputParenthesis(')');
      expect(controller.expression, '0');
      controller.inputDigit('2');
      controller.inputParenthesis(')');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      expect(controller.expression, '5');
    });

    test('رقم بعد از = عبارت تازه شروع می‌کند', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      controller.inputDigit('4');
      expect(controller.expression, '4');
    });

    test('عملگر بعد از = محاسبه را ادامه می‌دهد', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      controller.inputOperator('*');
      controller.inputDigit('2');
      controller.evaluate();
      expect(controller.expression, '10');
    });

    test('بازیابی از حالت خطا با فشردن عملگر', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('5');
      controller.inputOperator('/');
      controller.inputDigit('0');
      controller.evaluate();
      expect(controller.hasError, isTrue);
      controller.inputOperator('+');
      expect(controller.hasError, isFalse);
      expect(controller.preview, '0');
      expect(controller.expression, '0');
    });

    test('= تکراری روی نتیجه، تاریخچه را اسپم نمی‌کند', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('2');
      controller.inputOperator('+');
      controller.inputDigit('3');
      controller.evaluate();
      controller.evaluate();
      controller.evaluate();
      expect(controller.history.length, 1);
    });

    test('سقف طول عبارت برای همهٔ ورودی‌ها اعمال می‌شود', () {
      final CalculatorController controller = CalculatorController();
      for (int i = 0; i < CalculatorController.maxExpressionLength; i++) {
        controller.inputDigit('9');
      }
      final String before = controller.expression;
      expect(before.length, CalculatorController.maxExpressionLength);
      controller.inputDigit('1');
      controller.inputParenthesis('(');
      controller.togglePercent();
      controller.inputDecimalPoint();
      expect(controller.expression, before);
    });

    test('نتیجهٔ خیلی بزرگ (نماد علمی) دوباره قابل محاسبه است', () {
      final CalculatorController controller = CalculatorController();
      // 10^30 → 1e+30
      controller.inputDigit('1');
      controller.inputDigit('0');
      controller.inputOperator('^');
      controller.inputDigit('3');
      controller.inputDigit('0');
      controller.evaluate();
      expect(controller.hasError, isFalse);
      controller.inputOperator('*');
      controller.inputDigit('2');
      controller.evaluate();
      expect(controller.hasError, isFalse);
      expect(controller.expression, '2e+30');
    });

    test('تغییر علامت (±)', () {
      final CalculatorController controller = CalculatorController();
      controller.inputDigit('7');
      controller.toggleSign();
      expect(controller.expression, '-7');
      controller.toggleSign();
      expect(controller.expression, '7');
    });
  });
}
