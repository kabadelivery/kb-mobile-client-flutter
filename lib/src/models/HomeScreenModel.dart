import 'package:KABA/src/models/ShopProductModel.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/foundation.dart';
import 'dart:core';
import 'package:KABA/src/models/AdModel.dart';
import 'package:KABA/src/models/EvenementModel.dart';
import 'package:KABA/src/models/ShopModel.dart';


Iterable l;

class HomeScreenModel {

  /*/* feed */
/* top banners */
/* mainr estaurants */
/* in-page menu entities */ /* page --? best_seller ? cinema ? ect... */
/* gifList */ /* adsbanner */
/* group ads */
*/

  int serial_home;
  String feed;
  List<ShopModel> resto;
  List<AdModel> slider;
//  List<AdModel> kaba_pub;
  List<GroupAdsModel> groupad;
  List<HomeScreenSubMenuModel> subMenus;
  List<ShopProductModel> food_suggestions;

  AdModel event, promotion;

  HomeScreenModel({this.serial_home,
    this.feed,
    this.slider,
    this.resto,
    this.event,
    this.promotion,
    this.groupad,
    this.food_suggestions,
    this.subMenus});

  HomeScreenModel.fromJson(Map<String, dynamic> json) {

    serial_home = json['serial_home'];

    feed = json['feed'];
    /* manually get the json */

    l = json["resto"];
    resto = l?.map((resto) => ShopModel.fromJson(resto))?.toList();

    l = json["slider"];
    slider = l?.map((slider_model) => AdModel.fromJson(slider_model))?.toList();

    event = EvenementModel.fromJson(json["event"]);

    promotion = EvenementModel.fromJson(json["promotion"]);

    l = json["groupad"];
    groupad = l?.map((groupad) => GroupAdsModel.fromJson(groupad))?.toList();

    try {
      l = json["food_suggestions"];
      food_suggestions =
          l?.map((product) => ShopProductModel.fromJson(product))?.toList();
    } catch(e){
      xrint(e);
    }

    l = json["subMenus"];
    subMenus = l?.map((subMenus) => HomeScreenSubMenuModel.fromJson(subMenus))?.toList();
  }

  Map toJson () => {
    "serial_home" : (serial_home as int),
    "feed" : feed,
    "resto" : resto,
    "slider" : slider,
    "promotion" : promotion.toJson(),
    "event" : event.toJson(),
    "groupad" : groupad,
    "subMenus" : subMenus,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}

class HomeScreenSubMenuModel {

  /* best seller */
  /* events */
  /* cinema */
  /* all kinds of other things. */
  String title;
  String img;
  int destination;
  String link;

  HomeScreenSubMenuModel({this.title, this.img, this.destination, this.link});

  HomeScreenSubMenuModel.fromJson(Map<String, dynamic> json) {

    title = json['title'];
    img = json['img'];
    destination = json['destination'];
    link = json['link'];
  }

  Map toJson () => {
    "title" : title,
    "img" : img,
    "destination" : destination,
    "link" : link,
  };

  @override
  String toString() {
    return toJson().toString();
  }

}

class Destination {
  int BEST_SELLER;
  int EVENEMENTS;
  int WEB;
}

class GroupAdsModel {

  String title;
  String title_theme;
  AdModel big_pub;
  AdModel small_pub;
  List<AdModel> level_one;
  List<AdModel> level_two;


  GroupAdsModel({this.title, this.title_theme, this.big_pub, this.small_pub, this.level_one, this.level_two});

  GroupAdsModel.fromJson(Map<String, dynamic> json) {

    title = json['title'];
    title_theme = json['title_theme'];

    big_pub = AdModel.fromJson(json["big_pub"]);
    small_pub = AdModel.fromJson(json["small_pub"]);

    l = json["level_one"];
    level_one = l?.map((f) => AdModel.fromJson(f))?.toList();

    l = json["level_two"];
    level_two = l?.map((f) => AdModel.fromJson(f))?.toList();
  }

  Map toJson () => {
    "title" : title,
    "title_theme" : title_theme,
    "big_pub" : big_pub,
    "small_pub" : small_pub,
  };

  @override
  String toString() {
    return toJson().toString();
  }
}


