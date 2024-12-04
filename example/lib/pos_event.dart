
import 'package:serial_pos/pos_response.dart';

abstract class PosEvent {}

class ConnectEvent extends PosEvent {}

class DisconnectEvent extends PosEvent {}

class SendAmountEvent extends PosEvent {
  final int amount;
  final String payload;

  SendAmountEvent({required this.amount, required this.payload});
}

class CancelEvent extends PosEvent {}

class PosBuySuccessEvent extends PosEvent {
  final BuyResponse response;

  PosBuySuccessEvent(this.response);
}

class PosBuyFailedEvent extends PosEvent {
  final String errorCode;
  final String payload;

  PosBuyFailedEvent(this.errorCode, this.payload);
}
