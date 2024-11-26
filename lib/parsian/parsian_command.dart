import '../pos_command.dart';

class ParsianBuyCommand extends PosCommand {
  final int amount;

  ParsianBuyCommand({required this.amount});

  @override
  String buildCommand() {
    return """{"cmd": 10, "amount": $amount}""";
  }
}

class ParsianCancelCommand extends PosCommand {
  @override
  String buildCommand() {
    return """{"cmd":90}""";
  }
}
