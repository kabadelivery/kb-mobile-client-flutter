

import 'package:flutter/cupertino.dart';

const bool XRINT_DEBUG_VALUE = true;

xrint (dynamic message,{bool debug = XRINT_DEBUG_VALUE}){
  if (debug){
    debugPrint("XXX ${message}");
  }
}