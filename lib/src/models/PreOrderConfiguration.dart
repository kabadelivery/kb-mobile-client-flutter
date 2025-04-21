import 'package:flutter/foundation.dart';
import 'package:KABA/src/models/ShopModel.dart';

 
class PreOrderConfiguration {


  bool? is_preorder_allowed;
  bool? is_preorder_prepayed_allowed;
  bool? is_preorder_postpayed_allowed;
  List<String>? preorder_timeranges; // # 1100-1300 ; 1815-2045

  PreOrderConfiguration({this.is_preorder_allowed, this.is_preorder_prepayed_allowed, this.is_preorder_postpayed_allowed, this.preorder_timeranges});

  PreOrderConfiguration.fromJson(Map<String, dynamic> json) {

    is_preorder_allowed = json['is_preorder_allowed'];
    is_preorder_prepayed_allowed = json['is_preorder_prepayed_allowed'];
    is_preorder_postpayed_allowed = json['is_preorder_postpayed_allowed'];

    var l = json["preorder_timeranges"];
    preorder_timeranges = l?.map((String timerange) => (timerange))?.toList();
  }

  Map toJson () => {
    "is_preorder_allowed" : is_preorder_allowed,
    "is_preorder_prepayed_allowed" : is_preorder_prepayed_allowed,
    "is_preorder_postpayed_allowed" : is_preorder_postpayed_allowed,
    "priority" : preorder_timeranges,
  };

  @override
  String toString() {
    return toJson().toString();
  }

  static PreOrderConfiguration fake() {

    PreOrderConfiguration p = PreOrderConfiguration();
    p.is_preorder_postpayed_allowed = true;
    p.is_preorder_prepayed_allowed = true;
    p.is_preorder_allowed = true;
    p.preorder_timeranges = ["1100-1300", "1800-1900"];
    return p;
  }

} 
