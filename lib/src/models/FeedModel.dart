import 'package:flutter/foundation.dart';
import 'dart:core';

import 'package:kaba_flutter/src/models/NotificationFDestination.dart';

class FeedModel {

  /* feed is an entity */
  int id;
  String title;
  String pic;
  String content;
  String created_at;
  NotificationFDestination destination;

  FeedModel({this.id, this.title, this.pic, this.content, this.created_at,
    this.destination});

  FeedModel.fromJson(Map<String, dynamic> json) {

    id = json['id'];
    title = json['title'];
    pic = json['pic'];
    content = json['content'];
    created_at = json['created_at'];
    destination = NotificationFDestination.fromJson(json['destination']);
  }

  Map toJson () => {
    "id" : (id as int),
    "title" : title,
    "pic" : pic,
    "content" : content,
    "created_at" : created_at,
    "destination" : destination.toJson(),
  };

  @override
  String toString() {
    return toJson().toString();
  }

}