   import 'package:shared_preferences/shared_preferences.dart';

Future<bool> getIsExplanationSpaceVisible() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_explanation_space_visible');
  }