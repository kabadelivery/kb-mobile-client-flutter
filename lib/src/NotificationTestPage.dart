import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;

class NotificationTestPage extends StatefulWidget {

  static var routeName = "/NotificationTestPage";

  @override
  _NotificationTestPageState createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child:RaisedButton(

    child: Text("Test notif", style: TextStyle(color: Colors.red)),
    onPressed: ()=>sendAndRetrieveMessage(),
    )));
  }

  // Replace with server token from firebase console settings.
  final String serverToken = 'AAAA-vm6MJM:APA91bFGAiFy4g8s6UnGAWrR0qMUg1H4NKpZcdotMhZLXT6M_xShHrgAMIRNwDpWAAwCKjq0pVO3sx9aXc4Mm5rM7SC_UOofUNPoqqDSvrmgPQWnHUhCsAZ88tF8SJuixwRvY4ZMXfJr';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;



    Future<Map<String, dynamic>> sendAndRetrieveMessage() async {

      print ("On click");

//      await firebaseMessaging.requestNotificationPermissions(
//        const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
//      );
      Client http = Client();

      String token = await firebaseMessaging.getToken();

      final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: json.encode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'this is a body',
              'title': 'this is a title'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': token,
//            'topic': 'kaba_flutter'
          },
        ),
      );

      print("token is ${token}");
      print(response.body.toString());

     /* final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();*/
      print("On before onConfigure");
    /*  firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("INside on configure");
          completer.complete(message);
        },
      );*/

//      return completer.future;
  }

}

