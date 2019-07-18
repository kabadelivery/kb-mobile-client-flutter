import 'package:flutter/material.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

int hexToInt(String code) {
  return int.parse(code.substring(1, 7), radix: 16) + 0xFF000000;
}