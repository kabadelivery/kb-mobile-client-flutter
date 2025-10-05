import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/ShopProductModel.dart';

Widget Notation({required String text,int? count, ShopProductModel? food}) {

  double note = double.parse(text)<1?0.0:double.parse(text);

  return food==null?Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
       for (var i = 0; i < 5; i++)
        Icon(
          i < note ? Icons.star : Icons.star_border,
          color: KColors.primaryYellowColor,
          size: 16,
        ),
     ],
  ):Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('${text.substring(2,3)=="0"?text.substring(0,1):note.toStringAsFixed(1)}/5',style: TextStyle(color: KColors.primaryColor,fontSize: 12,fontWeight: FontWeight.bold),),
      SizedBox(width: 4,),
      Icon(Icons.star, color: KColors.primaryColor, size: 18) ,
    ],
  );
}

Future<Map?> showReviewDialog(BuildContext context,Widget dialog) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(20),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
              color: Colors.white,
              height: 500,
              width: 400,
              child: dialog
          ),
        ),
      );
    },
  );
}
