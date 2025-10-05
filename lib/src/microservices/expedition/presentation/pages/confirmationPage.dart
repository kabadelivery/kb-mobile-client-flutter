import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/microservices/expedition/presentation/pages/homepage.dart';
import 'package:KABA/src/microservices/kaba_chine/functions/contact.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/utils.dart';
import '../widget/popAnimation.dart';

class Confirmationpage extends StatefulWidget {
  const Confirmationpage({super.key});

  @override
  State<Confirmationpage> createState() => _ConfirmationpageState();
}

class _ConfirmationpageState extends State<Confirmationpage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>KabaExpeditionHomePage()));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>KabaExpeditionHomePage()));
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        color: KabaExpeditionColor.primary)
                    ,child: Row(
                    children: [
                      Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,),
                      SizedBox(width: 10,),
                      Text('En attente de confirmation',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                    ],
                  ),
                  ),
                ),
                SizedBox(height: 20,),
                PopInWidget(
                  duration: Duration(milliseconds: 700),
                  child: Container(
                    width: 330,
                    height: 250,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Color(0xFFEEF7FF),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 20,
                              offset: Offset(0, 3)),
                        ]
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right:0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Color(0xFFC8F7FE),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50),topRight: Radius.circular(15))
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                                color: Color(0xFFC8F7FE),
                                borderRadius: BorderRadius.only(topRight: Radius.circular(50),bottomLeft: Radius.circular(15))
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20,),
                              Container(
                                  width: 60,
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFE93F53),
                                            KabaExpeditionColor.primary
                                          ]


                                      )
                                  ),
                                  child: Center(child: Icon(CupertinoIcons.paperplane,color: Colors.white,size: 30,))
                              ),
                              Text("${AppLocalizations.of(context)!.translate('request_sent')}",style: TextStyle(color: KabaExpeditionColor.primary,fontWeight: FontWeight.bold,fontSize: 14),),
                              SizedBox(height: 15,),
                              Container(
                                  width: 330,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Flexible(child: Text("${AppLocalizations.of(context)!.translate('shipment_sent')}",textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12),
                                  ))),
                              SizedBox(height: 20,),
                              Container(
                                width: 300,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.watch_later_outlined,color: KabaExpeditionColor.primary,),
                                    Text("${AppLocalizations.of(context)!.translate('waiting_confirmation')}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                                    SizedBox()
                                  ],
                                ),

                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(height: 20,),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                PopInWidget(
                  duration: Duration(milliseconds: 900),
                  child: Container(
                    width: 330,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 20,
                              offset: Offset(0, 3)),
                        ]),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 50,
                            height:50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF39CF7B),
                                      Color(0xFF00A163)
                                    ]


                                )
                            ),
                            child: Center(child: Icon(CupertinoIcons.check_mark_circled,color: Colors.white,size: 30,))
                        ),
                        SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('next_steps')}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Container(
                              width: 250,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle,size: 12,color: KabaExpeditionColor.primary,),
                                      SizedBox(width: 5,),
                                      Flexible(child: Text("${AppLocalizations.of(context)!.translate('team_review')}",style: TextStyle(fontSize: 13,color: Colors.black54),)),

                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle,size: 12,color: KabaExpeditionColor.primary,),
                                      SizedBox(width: 5,),
                                      Flexible(child: Text("${AppLocalizations.of(context)!.translate('confirmation_soon')}",style: TextStyle(fontSize: 13,color: Colors.black54))),

                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle,size: 12,color: KabaExpeditionColor.primary,),
                                      SizedBox(width: 5,),
                                      Flexible(child: Text("${AppLocalizations.of(context)!.translate('tracking_available')}",style: TextStyle(fontSize: 13,color: Colors.black54))),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                PopInWidget(
                  duration: Duration(milliseconds: 1100),
                  child: Container(
                    width: 330,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Color(0xFFFDFBE8),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF3E3E3E).withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 20,)]
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 50,
                            height:50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFF3A100),
                                      Color(0xFFF66200)
                                    ]


                                )
                            ),
                            child: Center(child: Icon(Icons.watch_later_outlined,color: Colors.white,size: 30,))
                        ),
                        Column(
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('response_time')}",style: TextStyle(color:Color(0xFF974617),fontSize: 16,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("${AppLocalizations.of(context)!.translate('max_15min')}",style:TextStyle(color: Color(0xFFA9512E),fontSize:12,fontWeight: FontWeight.bold),),
                            SizedBox(height: 10,),
                            Text("${AppLocalizations.of(context)!.translate('contact_soon')}",style:TextStyle(color: Color(0xFFA9512E),fontSize: 12),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                PopInWidget(
                  duration: Duration(milliseconds: 1300),
                  child: Container(
                    width: 330,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                          elevation: 0,
                          highlightElevation: 0,
                          minWidth: 160,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: .5,color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          onPressed: (){
                            Navigator.of(context).pushReplacement(PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => KabaExpeditionHomePage(),
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
                          child: Text("${AppLocalizations.of(context)!.translate('back_home')}",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w100)),

                        ),
                        MaterialButton(
                          elevation: 0,
                          highlightElevation: 0,
                          minWidth: 160,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(width: .5,color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          onPressed: (){
                            contactWhatsApp(phoneNumber: "22892109474", message: "");
                          },
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.chat_bubble,color: Colors.black,size: 17,),
                              SizedBox(width: 10,),
                              Text("${AppLocalizations.of(context)!.translate('chat_support')}",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w100),),
                            ],
                          ),

                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}