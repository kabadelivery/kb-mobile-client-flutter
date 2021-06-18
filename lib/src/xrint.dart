

import 'package:flutter/cupertino.dart';

xrint (String message,{bool debug = false}){
  if (debug){
    debugPrint("${message}");
  }
}