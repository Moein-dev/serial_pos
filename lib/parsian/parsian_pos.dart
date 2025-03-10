import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:serial_pos/parsian/parsian_response.dart';
import 'package:serial_pos/parsian/parsian_response_parser.dart';
import 'package:serial_pos/pos_command.dart';
import 'package:serial_pos/pos_device.dart';
import 'package:serial_pos/serial_communication.dart';


import '../pos_response.dart';
import '../pos_response_parser.dart';

class ParsianPos implements PosDevice {
  late final SerialCommunication _serialCommunication;
  final _messageEventController = StreamController<PosResponse>.broadcast();
  final StringBuffer _messageBuffer = StringBuffer();
  int _messageLength = 0;
  static const headerSize = 4;
  String payload = "";

  ParsianPos(SerialCommunication sm) {
    _serialCommunication = sm;

    _listenToSerialMessages();
  }

  @override
  Stream<PosResponse> get onMessageEvent => _messageEventController.stream;

  @override
  PosResponseParser parser = ParsianResponseParser();

  @override
  Future<bool> connect({int baudRate = 19200}) async {
    final devices = await _serialCommunication.getAvailableDevices();
    if (devices.isNotEmpty) {
      bool isConnectionSuccess =
          await _serialCommunication.connect(devices[0], baudRate: baudRate);
      debugPrint('Connection Success: $isConnectionSuccess');
      return isConnectionSuccess;
    } else {
      return false;
    }
  }

  @override
  void disconnect() {
    _serialCommunication.disconnect();
  }

  @override
  void dispose() {
    _messageEventController.close();
  }

  @override
  Future<void> sendCommand(PosCommand command, {String? payload}) async {
    this.payload = payload ?? this.payload;

    String commandStr = command.buildCommand();
    String commandLength =
        commandStr.length.toString().padLeft(headerSize, '0');
    await _serialCommunication.sendData("$commandLength$commandStr\r\n");
  }

  void _listenToSerialMessages() {
    _serialCommunication.onMessageReceived.listen((event) {
      if (event != "0" && _messageBuffer.isEmpty) {
        _messageBuffer.write("0$event");
      } else {
        _messageBuffer.write(event);
      }

      debugPrint("message buffer: ${_messageBuffer.toString()}");

      try {
        _processMessage();
      } catch (e) {
        debugPrint("error in parsing response: $e");
        _messageBuffer.clear();
        _messageLength = 0;

        final response =
            ParsianFailedResponse(cmd: 10, resp: -2, payload: payload);
        _messageEventController.add(response);
      }
    });
  }

  void _processMessage() {
    if (_messageBuffer.length >= headerSize && _messageLength == 0) {
      final lengthString = _messageBuffer.toString().substring(0, headerSize);
      debugPrint("length: $lengthString");
      _messageLength = int.parse(lengthString);
    }

    debugPrint(
        "buffer length: ${_messageBuffer.length} == header length: ${_messageLength + headerSize}");

    if (_messageBuffer.length == _messageLength + headerSize) {
      final response = parser.parse(
          _messageBuffer.toString().substring(headerSize), payload);
      debugPrint("parsed response: $response");

      _messageBuffer.clear();
      _messageLength = 0;

      _messageEventController.add(response);
    }
  }
}
