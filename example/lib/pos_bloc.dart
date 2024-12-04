import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serial_pos/parsian/parsian_command.dart';
import 'package:serial_pos/parsian/parsian_pos.dart';
import 'package:serial_pos/parsian/parsian_response.dart';
import 'package:serial_pos/pos_device.dart';
import 'package:serial_pos/serial_communication.dart';
import 'package:serial_pos_example/pos_event.dart';
import 'package:serial_pos_example/pos_state.dart';


class PosBloc extends Bloc<PosEvent, PosState> {
  late final PosDevice _pos;

  PosBloc() : super(PosState.initial()) {
    final serialCommunication = SerialCommunication();
    _pos = ParsianPos(serialCommunication);

    on<ConnectEvent>(_onConnect);
    on<DisconnectEvent>(_onDisconnect);
    on<SendAmountEvent>(_onSendAmount);
    on<CancelEvent>(_onCancel);
    on<PosBuySuccessEvent>(_onBuySuccess);
    on<PosBuyFailedEvent>(_onBuyFailed);

    _pos.onMessageEvent.listen((event) {
      debugPrint("bloc: ${event.toString()}");

      if (event is ParsianBuyResponse) {
        add(PosBuySuccessEvent(event));
        // add(DisconnectEvent());
      } else if (event is ParsianFailedResponse) {
        add(PosBuyFailedEvent(event.resp.toString(), event.payload));
        // add(DisconnectEvent());
      }
    });
  }

  void _onBuySuccess(PosBuySuccessEvent event, Emitter<PosState> emit) {
    emit(
      state.copyWith(
        message:
            "Success: rrn is ${event.response.rrn}, payload: ${event.response.payload}",
        isLoading: false,
      ),
    );
  }

  void _onBuyFailed(PosBuyFailedEvent event, Emitter<PosState> emit) {
    var message = "Failed: response code ${event.errorCode}";
    if (event.payload.isNotEmpty) {
      message += ", payload: ${event.payload}";
    }
    emit(
      state.copyWith(
        message: message,
        isLoading: false,
      ),
    );
  }

  Future<void> _onConnect(ConnectEvent event, Emitter<PosState> emit) async {
    emit((state.copyWith(isLoading: true)));
    final isConnected = await _pos.connect();
    if (isConnected) {
      emit(state.copyWith(isConnected: true, isLoading: false));
    } else {
      emit(
        state.copyWith(
          message: "Cannot connect to POS device",
          isConnected: false,
          isLoading: false,
        ),
      );
    }
  }

  void _onDisconnect(DisconnectEvent event, Emitter<PosState> emit) {
    _pos.disconnect();
    emit(state.copyWith(isConnected: false, isLoading: false, message: ""));
  }

  Future<void> _onSendAmount(
      SendAmountEvent event, Emitter<PosState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final command = ParsianBuyCommand(amount: event.amount);
      await _pos.sendCommand(command, payload: event.payload);
    } catch (e) {
      emit(state.copyWith(message: "Error sending amount", isLoading: false));
    }
  }

  Future<void> _onCancel(CancelEvent event, Emitter<PosState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final command = ParsianCancelCommand();
      await _pos.sendCommand(command);
    } catch (e) {
      emit(state.copyWith(
          message: "Error cancelling transaction", isLoading: false));
    }
  }
}
