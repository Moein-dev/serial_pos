import 'package:flutter/material.dart';
import 'package:serial_pos/parsian/parsian_command.dart';
import 'package:serial_pos/parsian/parsian_pos.dart';
import 'package:serial_pos/parsian/parsian_response.dart';
import 'package:serial_pos/pos_device.dart';
import 'package:serial_pos/serial_communication.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  String _messageResult = '';
  Map<String, dynamic> data = {};
  bool _loading = false;
  bool _connected = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  late final SerialCommunication _serialCommunication = SerialCommunication();
  late final PosDevice _pos = ParsianPos(_serialCommunication);

  @override
  void initState() {
    super.initState();
    _initializePosListener();
  }

  void _initializePosListener() {
    _pos.onMessageEvent.listen((event) {
      setState(() {
        _loading = false;
        if (event is ParsianBuyResponse) {
          data = event.toJson();
          _messageResult =
              "Success: rrn is ${event.rrn}, payload: ${event.payload}";
        } else if (event is ParsianFailedResponse) {
          data = event.toJson();
          _messageResult =
              "Failed: response code ${event.resp.toString()}, payload: ${event.payload}";
        }
      });
    });
  }

  Future<void> _sendAmount() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final amount = _amountController.text;
    final amountInt = int.tryParse(amount);
    final payload = _payloadController.text;

    if (amountInt == null) {
      _showSnackBar("Invalid amount");
      setState(() => _loading = false);
      return;
    }

    try {
      final command = ParsianBuyCommand(amount: amountInt);
      await _pos.sendCommand(command, payload: payload);
    } catch (e) {
      _showSnackBar("Error sending command");
      setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _connect() async {
    final isConnected = await _pos.connect();
    if (isConnected) {
      setState(() => _connected = true);
      _showSnackBar("Connected");
    } else {
      _showSnackBar("Cannot connect to POS device");
    }
  }

  void _disconnect() {
    _pos.disconnect();
    setState(() {
      _connected = false;
      _loading = false;
    });
    _showSnackBar("Disconnected");
  }

  Future<void> _sendCancel() async {
    setState(() => _loading = true);
    try {
      final command = ParsianCancelCommand();
      await _pos.sendCommand(command);
    } catch (e) {
      _showSnackBar("Error cancelling command");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payloadController.dispose();
    _pos.disconnect();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextField(
            controller: _amountController,
            label: 'Enter amount',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16.0),
          _buildTextField(
            controller: _payloadController,
            label: 'Enter payload',
          ),
          const SizedBox(height: 16.0),
          Wrap(
            children: [
              _buildButton(
                label: 'Connect',
                onPressed: _connected ? null : _connect,
              ),
              const SizedBox(width: 16.0),
              _buildButton(
                label: 'Disconnect',
                onPressed: _connected ? _disconnect : null,
              ),
              const SizedBox(width: 16.0),
              _buildButton(
                label: 'Send',
                onPressed: _loading || !_connected ? null : _sendAmount,
              ),
              const SizedBox(width: 16.0),
              _buildButton(
                label: 'Cancel',
                onPressed: _loading && _connected ? _sendCancel : null,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            _messageResult,
            style: const TextStyle(fontSize: 18.0, color: Colors.blue),
          ),
          if(data.isNotEmpty)
          Text(
            data.toString(),
          ),
        ],
      ),
    );
  }
}
