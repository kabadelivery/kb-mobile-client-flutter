
import 'package:KABA/src/microservices/kaba_chine/core/constants.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../functions/contact.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
Widget contactAssitanceListWidget({required BuildContext context}) {
  Size size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child:  Container(
      width: size.width,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              spreadRadius: 1.0,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
      ),
      child: Column(
        children: [
          Container(
              width: size.width,
              height: 30,
              decoration: BoxDecoration(
                color:  Color(0xa6f1f1f1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),

              ),
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Icon(Icons.support_agent,color: Colors.black87,),
                  SizedBox(width: 10,),
                  Text(
                    "${AppLocalizations.of(context)!.translate('contact_and_support')}",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
          ),
          contactAssitanceWidget(
            border: false,
            context: context,
            title: "${AppLocalizations.of(context)!.translate('contact_us_whatsapp')}",
            subtitle: "${AppLocalizations.of(context)!.translate('support_7_days')}",
            onPress: ()=>contactWhatsApp(phoneNumber: "22892109474",message: ""),
            icon:Icon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 25, )
          ),
          contactAssitanceWidget(
              border: true,
              context: context,
              title: "${AppLocalizations.of(context)!.translate('train_yourself')}",
              subtitle: "${AppLocalizations.of(context)!.translate('link_to_training')}",
              onPress: ()=>contactWhatsApp(phoneNumber: "22892109474",message: AppLocalizations.of(context)!.translate('kaba_chine_tutorial_message')),
              icon:Icon(FontAwesomeIcons.book, color:KabaChineColors.info, size: 15, )
          ),
          SizedBox(height: 20)
        ],
      ),
    ),
  );

}

Widget contactAssitanceWidget({required BuildContext context,required String title,required String subtitle,required Icon icon,Function()? onPress,required bool border}) {
  Size size = MediaQuery.of(context).size;
  return Container(
    width: size.width*.9,
    decoration: BoxDecoration(
      border:border? Border(top: BorderSide(color: Colors.black12)):null,

        color: Colors.white
    ),
    child: MaterialButton(
      onPressed: onPress,
      child: Padding(
        padding: EdgeInsets.all( 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           Row(
             children: [
               Container(
                   width: 40,
                   height:40,
                   decoration: BoxDecoration(
                     color: icon.color!.withOpacity(0.1),
                     borderRadius: BorderRadius.circular(50),
                   ),
                   child: icon
               ),
               SizedBox(width: 10,),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(title,style: TextStyle(color: Colors.black87,fontSize:12,fontWeight: FontWeight.normal),),
                   Container(
                       width: size.width*.54,
                       height: 30,
                       child: Text(subtitle,style: TextStyle(color: Colors.black54,fontSize:10),)),
                 ],
               ),
             ],
           ),
            Icon(Icons.arrow_forward_ios_sharp, color: Colors.black38, size: 15,),

          ],
        ),
      ),
    ),
  );
}