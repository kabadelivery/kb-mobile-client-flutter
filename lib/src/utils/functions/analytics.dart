
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> logButtonPress(String buttonName) async {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
    name: 'button_press',
    parameters: {'button_name': buttonName},
  );
}