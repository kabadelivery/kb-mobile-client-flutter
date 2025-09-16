import 'package:KABA/src/microservices/expedition/Enums/expedition_type.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/expedition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../../kaba_chine/core/utils.dart';
import '../../core/utils.dart';

Widget ExpeditionInternationalBox({required BuildContext context}){
  return   Container(
    height: 200,
    width: 270,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
      border: Border.all(color: KColors.primaryColor,width: .5),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding:EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color:KabaExpeditionColor.primary,
          ),
          child: Icon(Icons.local_shipping_outlined,color: Colors.white,size: 30,),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_outlined,color: KabaExpeditionColor.primary,size: 16,),
                SizedBox(width: 5,),
                Text("Par voie terrestre",style: TextStyle(fontSize: 12,color: Colors.black87,fontFamily: 'Inter'),),

              ],
            ),
            Row(
              children: [
                Icon(FontAwesomeIcons.earthAfrica,color: KabaExpeditionColor.primary,size: 16,),
                SizedBox(width: 5,),
                Text("7 pays disponibles",style: TextStyle(fontSize: 12,color: Colors.black87,fontFamily: 'Inter'),),

              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: (){
            Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => Expedition(type: ExpeditionType.international),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end);
                  var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                  return SlideTransition(
                      position: tween.animate(curvedAnimation),
                      child: child
                  );
                }
            ));
           },
          child: Container(
            margin: EdgeInsets.only(top: 20),
            width: 220,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFCC1E44),
                  Color(0xFFB71B3E),
                  Color(0xFFA11738),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Expédier maintenant",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: Colors.white,fontFamily: 'Inter'),),
                SizedBox(width: 5,),
                Icon(Icons.arrow_forward,color: Colors.white,size: 12,)
              ],
            ),
          ),
        )
      ],
    ),
  );
}