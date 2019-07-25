import 'package:kaba_flutter/src/models/NotificationFDestination.dart';



class NotificationItem {

  String title;
  String body;
  String image_link;
  NotificationFDestination destination;
  int priority = 0;

  NotificationItem({this.title, this.body, this.image_link, this.destination, this.priority});

  NotificationItem.fromJson(Map<String, dynamic> json) {

    title = json['title'];
    body = json['body'];
    image_link = json['image_link'];
    destination = json['destination'];
    priority = json['priority'];
  }


  Map toJson () => {
    "title" : title,
    "body" : body,
    "image_link" : image_link,
    "destination" : destination,
    "priority" : (priority as int),
  };


  @override
  String toString() {
    return toJson().toString();
  }

}