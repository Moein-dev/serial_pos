import 'package:serial_pos/pos_response.dart';

abstract class PosResponseParser {
  PosResponse parse(String message,String payload);
}
