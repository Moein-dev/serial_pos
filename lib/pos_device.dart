
import 'package:serial_pos/pos_command.dart';
import 'package:serial_pos/pos_response.dart';
import 'package:serial_pos/pos_response_parser.dart';

abstract class PosDevice {
  late PosResponseParser parser;

  Stream<PosResponse> get onMessageEvent;

  Future<bool> connect({int baudRate = 19200});

  void disconnect();

  // after dispose you cannot use the pos instance ANY MORE. call this function
  // when you want to clear memory and close the app. otherwise you should create
  // another instance
  void dispose();

  Future<void> sendCommand(PosCommand command, {String? payload});
}
