import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:usb_serial_communication/models/device_info.dart';
import 'package:usb_serial_communication/usb_serial_communication.dart';

class SerialCommunication {
  final _usbSerialCommunicationPlugin = UsbSerialCommunication();

  Stream<String> get onMessageReceived =>
      _usbSerialCommunicationPlugin
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
      _usbSerialCommunicationPlugin
          .getDeviceConnectionListener()
          .receiveBroadcastStream()
          .map((isConnected) {
        return isConnected;
      });

  Future<List<DeviceInfo>> getAvailableDevices() async {
    return await _usbSerialCommunicationPlugin.getAvailableDevices();
  }

  Future<bool> connect(DeviceInfo device, {int baudRate = 19200}) async {
    return await _usbSerialCommunicationPlugin.connect(device, baudRate);
  }

  Future<void> disconnect() async {
    await _usbSerialCommunicationPlugin.disconnect();
  }

  Future<void> sendData(String data) async {
    final commandBytes = Uint8List.fromList(utf8.encode(data));
    await _usbSerialCommunicationPlugin.write(commandBytes);
  }
}
