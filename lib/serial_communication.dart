import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';

class SerialCommunication {
  final _flutterSerialCommunicationPlugin = FlutterSerialCommunication();

  Stream<String> get onMessageReceived => _flutterSerialCommunicationPlugin
          .getSerialMessageListener()
          .receiveBroadcastStream()
          .map((event) {
        return decodeEvent(event);
      });

  String decodeEvent(List<int> event) {
    try {
      String decodedData = utf8.decode(event);
      return decodedData;
    } catch (e) {
      return '?' * event.length;
    }
  }

  Stream<bool> get onConnectionReceived => _flutterSerialCommunicationPlugin
          .getDeviceConnectionListener()
          .receiveBroadcastStream()
          .map((isConnected) {
        return isConnected;
      });

  Future<List<DeviceInfo>> getAvailableDevices() async {
    return await _flutterSerialCommunicationPlugin.getAvailableDevices();
  }

  Future<bool> connect(DeviceInfo device, {int baudRate = 19200}) async {
    return await _flutterSerialCommunicationPlugin.connect(device, baudRate);
  }

  Future<void> disconnect() async {
    await _flutterSerialCommunicationPlugin.disconnect();
  }

  Future<void> sendData(String data) async {
    debugPrint("sending: $data");
    final commandBytes = Uint8List.fromList(utf8.encode(data + "\r\n"));
    await _flutterSerialCommunicationPlugin.write(commandBytes);
  }
}

class FakeSerialCommunication {
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  final fakeMessages = [
    '0236{"cmd":10,"resp":0,"pan":"621986**0974","rrn":"745072278301","terminal":"45044286","trace":"148308","serial":"000169","amount":"4160000","settlement":"4160000","discount":"0","data1":"BK005?03002048RL0011FP0012SP0012T90010NF0072000001"}',
    '0234{"cmd":10,"resp":0,"pan":"621986**0974","rrn":"245072278307","terminal":"45044286","trace":"148308","serial":"000169","amount":"416000","settlement":"416000","discount":"0","data1":"BK005?03002048RL0011FP0012SP0012T90010NF0072000001"}',
    '0234{"cmd":10,"resp":0,"pan":"621986**0974","rrn":"545172268307","terminal":"45044286","trace":"148308","serial":"000169","amount":"116000","settlement":"416000","discount":"0","data1":"BK005?03002048RL0011FP0012SP0012T90010NF0072000001"}',
    '0020{"cmd":10,"resp":99}',
    '0020{"cmd":90,"resp":99}',
  ];

  Stream<String> get onMessageReceived => _messageController.stream;

  Stream<bool> get onConnectionReceived => _connectionController.stream;

  Future<List<DeviceInfo>> getAvailableDevices() async {
    return [
      DeviceInfo(deviceId: 1, deviceName: "Fake Device"),
    ];
  }

  Future<bool> connect(DeviceInfo device, {int baudRate = 19200}) async {
    await Future.delayed(const Duration(seconds: 1));
    _connectionController.add(true); // Simulate connection success
    return true;
  }

  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connectionController.add(false); // Simulate disconnection
  }

  Future<void> sendData(String data) async {
    debugPrint('Fake sending data: $data');

    fakeMessages.shuffle();
    final message = fakeMessages.first;

    await Future.delayed(const Duration(seconds: 4));

    for (var char in message.split('')) {
      _messageController.add(char);
    }
  }

  void dispose() {
    _messageController.close();
    _connectionController.close();
  }
}
