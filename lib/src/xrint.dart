import 'package:flutter/cupertino.dart';

const bool XRINT_DEBUG_VALUE = false;

xrint(dynamic message, {bool debug = XRINT_DEBUG_VALUE}) {
  if (debug) {
    debugPrint("XXX ${message}");
  }
}
