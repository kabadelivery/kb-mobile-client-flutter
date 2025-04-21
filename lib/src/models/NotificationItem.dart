import 'dart:convert';

import 'package:KABA/src/models/NotificationFDestination.dart';

class NotificationItem {
  String? title;
  String? body;
  String? image_link;
  NotificationFDestination? destination;
  String? priority;

  NotificationItem(
      {this.title,
      this.body,
      this.image_link,
      this.destination,
      this.priority});

  NotificationItem.fromJson(Map<String, dynamic> raw) {
    title = raw['title'];
    body = raw['body'];
    image_link = raw['image_link'];
    priority = raw['priority'];
  }

  Map toJson() => {
        "title": title,
        "body": body,
        "image_link": image_link,
//    "destination" : destination,
        "priority": (priority as int),
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
