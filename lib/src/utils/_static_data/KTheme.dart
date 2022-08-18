import 'package:flutter/material.dart';
import 'package:KABA/src/utils/functions/Utils.dart';

class KColors {
  static const String primaryColorCode = "#cc1641";

  static const Color primaryColor =
      Color.fromRGBO(204, 22, 65, 1); //exToColor(primaryColorCode);
  static const Color primaryDarkColor = Color.fromRGBO(118, 15, 39, 1);

  static const Color primaryYellowColor = Color.fromRGBO(255, 204, 51, 1);
  static const Color primaryYellowDarkColor = Color.fromRGBO(115, 95, 11, 1);

  static final Color mGreen = hexToColor("#00695c");
  static final Color mBlue = hexToColor("#1976D2");

  static final Color buy_category_button_bg = hexToColor("#f7f7f7");

  static final Color new_gray = hexToColor("#f7f7f7");
  static final Color new_black = hexToColor("#1e1e1e");

  static final Color chat_transparent_blue = Color.fromRGBO(24, 119, 213, 0.1);  // hexToColor("#F4F8FD");

//  00695c
  static final Color primaryColorTransparentADDTOBASKETBUTTON =
      hexToColor("#FFF7F9");
  static final Color primaryColorSemiTransparentADDTOBASKETBUTTON =
      hexToColor("#ffd9e2");

  static MaterialColor colorCustom = MaterialColor(hexToInt("#cc1641"), color);
  static MaterialColor colorMainYellow =
      MaterialColor(hexToInt("#FFC102"), color);
  static MaterialColor white = MaterialColor(hexToInt("#ffffff"), color);
  static MaterialColor darkish = MaterialColor(hexToInt("#000000"), color);

  static Map<int, Color> color = {
    50: Color.fromRGBO(204, 22, 65, 1),
    100: Color.fromRGBO(204, 22, 65, 1),
    200: Color.fromRGBO(204, 22, 65, 1),
    300: Color.fromRGBO(204, 22, 65, 1),
    400: Color.fromRGBO(204, 22, 65, 1),
    500: Color.fromRGBO(204, 22, 65, 1),
    600: Color.fromRGBO(118, 15, 39, 1),
    700: Color.fromRGBO(118, 15, 39, 1),
    800: Color.fromRGBO(118, 15, 39, 1),
    900: Color.fromRGBO(118, 15, 39, 1),
  };

/* buttons i use often */
}

class KStyles {
  static final TextStyle hintTextStyle_gray =
      TextStyle(color: Colors.grey.shade600, fontSize: 13);
  static final TextStyle hintTextStyle_gray_11 =
      TextStyle(color: Colors.grey.shade600, fontSize: 11);
}

class CommandStateColor {
  static final Color waiting = hexToColor("#666666");
  static final Color cooking = hexToColor("#e65100");
  static final Color shipping = hexToColor("#e2ae01");
  static final Color delivered = hexToColor("#00695c");
  static final Color cancelled = hexToColor("#000000");
}
