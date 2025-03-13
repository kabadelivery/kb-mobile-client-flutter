  import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../localizations/AppLocalizations.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';

Widget BuildExplanationSpace(BuildContext context,WidgetRef ref,String explanation,String animationUrl){
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context,double value,child){
    return Opacity(
      opacity: value,
    child: Transform.scale(
        scale: value,
        child: AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(10),
      height: 230,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
             color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        Container(
          height: 30,
          width: 30,
       child: GestureDetector(
        onTap: ()async{
          ref.read(outOfAppScreenStateProvier.notifier).setIsExplanationSpaceVisible(false);
          ref.read(outOfAppScreenStateProvier).is_explanation_space_visible=false;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_explanation_space_visible', false);
        },
        child: Icon(Icons.close,color: Colors.grey,),
       ),
       ),
          Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 20,),
      Container(
        width: 250,
        height: 150,
        child: Text("${explanation}",style: TextStyle(fontSize: 14,color:  Colors.black,fontFamily: "Inter"),),
      ),
      Lottie.network(animationUrl,width: 170,height: 170,)
      ],)
        ],
      )
   )
        )
        );
        }
        )
        ; }