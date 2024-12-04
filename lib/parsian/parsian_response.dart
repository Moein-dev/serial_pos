import 'dart:convert';

import '../pos_response.dart';

class ParsianBuyResponse extends BuyResponse {
  final String terminal;
  final String settlement;
  final String discount;
  final String data1;

  ParsianBuyResponse({
    required super.rrn,
    required super.dateTime,
    required super.serial,
    required super.trace,
    required super.amount,
    required super.cardNumber,
    required super.maskedCardNumber,
    required super.payload,
    required this.terminal,
    required this.settlement,
    required this.discount,
    required this.data1,
  });

  // Factory constructor to create a ParsianBuyResponse instance from JSON
  factory ParsianBuyResponse.fromJson(String jsonString, String payload) {
    final json = jsonDecode(jsonString);

    return ParsianBuyResponse(
      rrn: json['rrn'],
      dateTime: json['datetime'] ?? DateTime.now().toString(),
      serial: json['serial'],
      trace: json['trace'],
      amount: json['amount'],
      cardNumber: json['pan'],
      maskedCardNumber: json['pan'],
      terminal: json['terminal'],
      settlement: json['settlement'],
      discount: json['discount'],
      data1: json['data1'] ?? "",
      payload: payload,
    );
  }

  // Method to convert a ParsianBuyResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'rrn': rrn,
      'dateTime': dateTime,
      'serial': serial,
      'trace': trace,
      'amount': amount,
      'cardNumber': cardNumber,
      'maskedCardNumber': maskedCardNumber,
      'data1': data1,
    };
  }

  @override
  String toString() {
    return "Success: ${toJson().toString()}";
  }
}

class ParsianResponse extends PosResponse {
  int cmd;
  int resp;

  // Constructor
  ParsianResponse({
    required this.cmd,
    required this.resp,
    required super.payload,
  });

  // Factory constructor to create an instance from JSON
  factory ParsianResponse.fromJson(
    String jsonString,
    String payload,
  ) {
    final json = jsonDecode(jsonString);
    return ParsianResponse(
      cmd: json['cmd'],
      resp: json['resp'],
      payload: payload,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cmd': cmd,
      'resp': resp,
    };
  }
}

class ParsianFailedResponse extends PosResponse {
  int cmd;
  int resp;

  // Constructor
  ParsianFailedResponse({
    required this.cmd,
    required this.resp,
    required super.payload,
  });

  // Factory constructor to create an instance from JSON
  factory ParsianFailedResponse.fromJson(String jsonString, String payload) {
    final json = jsonDecode(jsonString);
    return ParsianFailedResponse(
      cmd: json['cmd'],
      resp: json['resp'],
      payload: payload,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cmd': cmd,
      'resp': resp,
    };
  }

  @override
  String toString() {
    return "Failed: ${toJson().toString()}";
  }
}
