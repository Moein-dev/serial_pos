import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_serial_communication/flutter_serial_communication.dart';
import 'package:flutter_serial_communication/models/device_info.dart';

class SerialCommunication {
  final _flutterSerialCommunicationPlugin = FlutterSerialCommunication();

  Stream<String> get onMessageReceived =>
      _flutterSerialCommunicationPlugin
          .getSerialMessageListener()
          .receiveBroadcastStream()
          .map((event) {
        try {
          // Attempt to decode the event
          String decodedData = utf8.decode(event);
          return decodedData;
        } catch (e) {
          // Handle decoding error
          return "?"; // or handle error as needed
        }
      });

  Stream<bool> get onConnectionReceived =>
      _flutterSerialCommunicationPlugin
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
    final commandBytes = Uint8List.fromList(utf8.encode(data));
    await _flutterSerialCommunicationPlugin.write(commandBytes);
  }
}
