import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serial_pos_example/pos_bloc.dart';
import 'package:serial_pos_example/pos_state.dart';

import 'pos_event.dart';

class MainWidget extends StatelessWidget {
  final TextEditingController _amountController =
      TextEditingController(text: "2000");
  final TextEditingController _payloadController =
      TextEditingController(text: "123456");

  MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PosBloc(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField(
                controller: _amountController, label: 'Enter amount'),
            const SizedBox(height: 16.0),
            _buildTextField(
                controller: _payloadController, label: 'Enter payload'),
            const SizedBox(height: 16.0),
            BlocBuilder<PosBloc, PosState>(
              builder: (context, state) {
                return Wrap(
                  children: [
                    _buildButton(
                      label: 'Connect',
                      onPressed: !state.isConnected
                          ? () => context.read<PosBloc>().add(ConnectEvent())
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    _buildButton(
                      label: 'Disconnect',
                      onPressed: state.isConnected
                          ? () => context.read<PosBloc>().add(DisconnectEvent())
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    _buildButton(
                      label: 'Send',
                      onPressed: state.isConnected && !state.isLoading
                          ? () {
                              final amount =
                                  int.tryParse(_amountController.text);
                              final payload = _payloadController.text;
                              if (amount != null) {
                                context.read<PosBloc>().add(SendAmountEvent(
                                    amount: amount, payload: payload));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invalid amount')),
                                );
                              }
                            }
                          : null,
                    ),
                    const SizedBox(width: 16.0),
                    _buildButton(
                      label: 'Cancel',
                      onPressed: state.isConnected && state.isLoading
                          ? () => context.read<PosBloc>().add(CancelEvent())
                          : null,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            BlocListener<PosBloc, PosState>(
              listener: (context, state) {
                if (state.message.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                } else if (state.isConnected && state.message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Connected")),
                  );
                } else if (!state.isConnected && !state.isLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Disconnected")),
                  );
                }
              },
              listenWhen: (previous, current) {
                // Only trigger the listener if the current state is different from the previous state
                return previous.message != current.message ||
                    previous.isConnected != current.isConnected;
              },
              child: BlocBuilder<PosBloc, PosState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const CircularProgressIndicator();
                  } else {
                    return Text(state.message);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton(
      {required String label, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
