import 'package:flutter/foundation.dart';
import 'dart:core';


 class KabaShippingMan {

   int id;
   String name;
   String current_location;
   String vehicle_serial_code;
   String last_update;
   String workcontact;
   String pic;
   bool is_available = false; // 0 unchecked, 1 checked


   KabaShippingMan({this.id, this.name, this.current_location, this.vehicle_serial_code, this.last_update,
     this.workcontact, this.pic, this.is_available});

   KabaShippingMan.fromJson(Map<String, dynamic> json) {

     id = json['id'];
     name = json['name'];
     current_location = json['current_location'];
     vehicle_serial_code = json['vehicle_serial_code'];
     last_update = json['last_update'];
     workcontact = json['workcontact'];
     pic = json['pic'];
     is_available = json['is_available'];
   }

   Map toJson () => {
     "id" : (id as int),
     "name" : name,
     "current_location" : current_location,
     "vehicle_serial_code" : vehicle_serial_code,
     "last_update" : last_update,
     "workcontact" : workcontact,
     "pic" : pic,
     "is_available" : is_available,
   };

   @override
   String toString() {
     return toJson().toString();
   }

}

