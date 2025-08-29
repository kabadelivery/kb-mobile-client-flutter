import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/ShopProductModel.dart';

Widget Notation({required String text,int? count, ShopProductModel? food}) {

  double note = double.parse(text)<1?0.0:double.parse(text);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for(int i=1;i<=5;i++)
        Icon(
          i<=note?Icons.star:Icons.star_border,
          color: Colors.amber,
          size: 14,
        ),
     count!=null? Text("($count)", style: TextStyle(fontSize: 10, color: Colors.black87)):Container()
     ],
  );
}