/// خطای مربوط به تحلیل یا محاسبهٔ یک عبارت ریاضی.
class CalculatorException implements Exception {
  final String message;
  const CalculatorException(this.message);

  @override
  String toString() => message;
}
