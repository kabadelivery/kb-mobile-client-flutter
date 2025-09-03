import 'package:KABA/src/microservices/expedition/Enums/expedition_type.dart';
import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../utils/_static_data/KTheme.dart';
import '../widget/expedition_type_box.dart';

class KabaExpeditionHomePage extends StatefulWidget {
  const KabaExpeditionHomePage({super.key});

  @override
  State<KabaExpeditionHomePage> createState() => _KabaExpeditionHomePageState();
}

class _KabaExpeditionHomePageState extends State<KabaExpeditionHomePage> {

  ExpeditionType selectedType = ExpeditionType.international;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
   
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width:MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                  color: KColors.primaryColor
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.box,color: Colors.white,size: 19,),
                        SizedBox(width: 5,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("KABA",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                            Text("Expédition",style: TextStyle(color: Colors.white,fontSize: 12),)
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: (){}, icon: Icon(Icons.phone_outlined,color: Colors.white,)),
                        IconButton(onPressed: (){}, icon: Icon(Icons.messenger_outline,color: Colors.white,)),
                        MaterialButton(
                          elevation: 0,
                          onPressed: (){},child: Text("Suivre son colis",style: TextStyle(color: Colors.white,fontSize: 11),),
                          minWidth: 80,height: 30,
                          shape: RoundedRectangleBorder(side: BorderSide(width: 1,color:Colors.white),borderRadius: BorderRadius.circular(20)),)
                      ],
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 100,
                color: Colors.white,
                child:Stack(
                  children: [

                    Positioned(
                        bottom:0,
                        child: Image.asset("assets/images/png/expedition_afrique.png",
                            opacity: AlwaysStoppedAnimation(0.6)
                            ,width: MediaQuery.of(context).size.width,fit: BoxFit.cover,)),
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 270)/2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30,),
                          Text('Expédier un colis',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22,color: KColors.primaryColor,fontFamily: 'Inter'),),
                          SizedBox(height: 5,),
                          Container(
                              width: 270,
                              child: Text("Choisissez votre destination et expédiez en toute sécurité",style: TextStyle(fontSize: 12,color: Colors.black87,fontFamily: 'Inter'),)),
                          SizedBox(height: 10,),
                          Container(
                            width: 270,
                            height: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  )
                                ],
                                border: Border.all(color: Colors.grey.shade300,width: .5)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:120,
                                  margin: EdgeInsets.only(left: 2),
                                  height: 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: KColors.primaryColor,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.grey.shade300,width: .5)
                                  ),
                                  child: Text("International",style: TextStyle(color: Colors.white,fontSize: 14,fontFamily: 'Inter'),),
                                ),
                                Container(
                                  width:120,
                                  margin: EdgeInsets.only(right: 2),
                                  height: 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Colors.white,width: .5)
                                  ),
                                  child: Text("National",style: TextStyle(color: Colors.black87,fontSize: 14,fontFamily: 'Inter'),),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          ExpeditionInternationalBox(context:context),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
