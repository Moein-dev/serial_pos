abstract class PosResponse {
  final String payload;

  PosResponse({required this.payload});
}

abstract class BuyResponse extends PosResponse {
  final String rrn;
  final String dateTime;
  final String serial;
  final String trace;
  final String amount;
  final String cardNumber;
  final String maskedCardNumber;

  BuyResponse({
    required this.rrn,
    required this.dateTime,
    required this.serial,
    required this.trace,
    required this.amount,
    required this.cardNumber,
    required this.maskedCardNumber,
    required super.payload,
  });
}