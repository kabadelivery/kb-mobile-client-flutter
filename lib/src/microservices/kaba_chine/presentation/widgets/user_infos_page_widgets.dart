import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget userIdInfo({required BuildContext context,required String userId}) {
  Size size = MediaQuery.of(context).size;
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child:  Container(
      width: size.width,
      height: 230,
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
                  color: Color(0xffececec),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    Icon(Icons.badge,color: Colors.black87,),
                    SizedBox(width: 10,),
                    Text(
                      "Votre Identifiant Client",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              ),
              SizedBox(height: 10,),
              Container(
                width: size.width*.80,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: KabaChineColors.border),
                  gradient: LinearGradient(
                    colors: [
                      Color(0x77bbd3ff),
                      Color(0x77a2b8e1),

                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userId,
                          style: TextStyle(
                            color: KabaChineColors.secondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: userId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Identifiant copié dans le presse-papiers"),
                              ),
                            );
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color:   Color(0x225798ff),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(Icons.copy, color: KabaChineColors.info,size: 16,),
                          ),
                        ),
                      ],
                    ),
                    Text("VOTRE CODE CLIENT",style: TextStyle(color: Colors.black54,fontSize: 12,fontWeight: FontWeight.bold),)
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: size.width*.85,
                height: 90,
                decoration: BoxDecoration(
                  color:  Color(0x2076a8ff),
                  borderRadius: BorderRadius.circular(10),
                  border: Border(left: BorderSide(width: 3,color: KabaChineColors.info)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info,color: KabaChineColors.info,),
                      SizedBox(width: 10,),
                      Container(
                        width: size.width*.7,

                        child: Text("Important : Communiquez votre code client à votre fournisseur pour qu'il l'inscrive sur votre colis. Cela permettra une identification rapide et un traitement prioritaire."
                        ,style: TextStyle(fontSize: 11),
                          textAlign: TextAlign.start,
                        ),
                      )
                    ],
                  ),
                ),
              )

          ],
        ),
    ),
  );

}