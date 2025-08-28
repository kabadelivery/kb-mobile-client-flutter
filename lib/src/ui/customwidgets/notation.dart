import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget Notation(String text) {
  double note = double.parse(text);
  return Container(
    padding: EdgeInsets.symmetric(horizontal:  5),
    decoration:BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Color(0xf7ffdec1),

    ) ,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.star,
          color: Color(0xf7ff7300), size: 16,),
        SizedBox(width: 3),
        Text(note<1?"3.0":text,style: TextStyle(color: Color(0xf7ff7300)),)
      ],
    ) ,
  );
}