import 'package:flutter/foundation.dart';
import 'package:serial_pos/parsian_response.dart';

import 'pos_response.dart';
import 'pos_response_parser.dart';

class ParsianResponseParser implements PosResponseParser {
  @override
  PosResponse parse(String message, String payload) {
    debugPrint("Response: $message");

    try {
      final response = ParsianResponse.fromJson(message, payload);
      switch (response.resp) {
        case 90:
          return ParsianFailedResponse.fromJson(message, payload);
        case 0:
          return ParsianBuyResponse.fromJson(message, payload);
        default:
          return ParsianFailedResponse.fromJson(message, payload);
      }
    } catch (e) {
      return ParsianFailedResponse(cmd: 10, resp: -1, payload: payload);
    }
  }
}
