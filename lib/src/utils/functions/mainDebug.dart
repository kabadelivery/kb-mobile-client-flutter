

import 'dart:core';

void main () {


  String dt = DateTime.now().toString();
  print ("we good  - $dt");



 var ds = DateTime.parse(dt);
 print(" -- ${ds.second} -- ");
}