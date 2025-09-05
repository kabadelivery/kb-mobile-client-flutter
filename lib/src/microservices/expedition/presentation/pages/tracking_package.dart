import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../core/utils.dart';

class TrackingPackage extends StatefulWidget {
  const TrackingPackage({super.key});

  @override
  State<TrackingPackage> createState() => _TrackingPackageState();
}

class _TrackingPackageState extends State<TrackingPackage> {
  int star_selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            InkWell(
              onTap: (){
                Navigator.pop(context);
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
                  Text('Suivis du colis',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
                ],
              ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 330,
              height: 160,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFFECFDF5),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFF01792E).withOpacity(0.2),
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
                          color: Color(0xFFD2F9E1),
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
                          color: Color(0xFFD2F9E1),
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
                                      Color(0xFF39CF7B),
                                      Color(0xFF00A163)
                                    ]


                                )
                            ),
                            child: Center(child: Icon(CupertinoIcons.check_mark_circled,color: Colors.white,size: 40,))
                        ),
                        Text("🎉 Votre colis a été livré !",style: TextStyle(color:Color(0xFF3D6F2E),fontWeight: FontWeight.bold,fontSize: 18),),
                        SizedBox(height: 15,),
                        Container(
                            width: 330,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Merci d’avoir choisi KABA Expédition",textAlign: TextAlign.center,
                            
                              style: TextStyle(fontSize: 12,color: Color(0xFF01792E)),
                            )),
                        SizedBox(height: 20,),

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
            SizedBox(height: 20,),
            Container(
              width: 330,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black38.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 20,
                      offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 330,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(

                      color: Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                    ),
                    child: Text("Récapitulatif de livraison"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            Text("Numéro",style: TextStyle(fontSize: 12,color: Colors.black87),),
                            Text("KB12345678",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold),),
                            Row(
                              children: [
                                Text("Route : ",style: TextStyle(fontSize: 12,color: Colors.black87),),
                                Row(
                                  children: [
                                    Text("Lomé",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold)),
                                    Icon(Icons.arrow_forward,color: Colors.black,size: 12,),
                                    Text("Accra",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold))
                                  ],
                                )
                              ],
                            ),
                          ]
                        ),
                        SizedBox(height: 20,),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[
                              Text("Livré le :",style: TextStyle(fontSize: 12,color: Colors.black87),),
                              Text("20 Aôut 2025 15:30",style: TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.bold),),
                              Row(
                                children: [
                                  Text("Durée : ",style: TextStyle(fontSize: 12,color: Colors.black87),),
                                  Text("3 jours",style: TextStyle(fontSize: 12,color: Color(0xFF01792E),fontWeight: FontWeight.bold)),

                                ],
                              ),
                            ]
                        ),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),

                ],
              ),

            ),
            SizedBox(height: 20,),

            Container(
                width: 330,
                alignment:Alignment.center,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black38.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 20,
                          offset: Offset(0, 3)),
                    ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Comment évaluez-vous notre colis ?",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 13),),
                  Container(
                    alignment: Alignment.center,
                    width: 330,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 50,),
                        Flexible(
                          child: ListView.builder(
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              physics:NeverScrollableScrollPhysics(),
                              itemBuilder: (context,index){
                                return Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          star_selected = index+1;
                                        });
                                      },
                                      child: Icon(FontAwesomeIcons.solidStar
                                          ,color: index<star_selected?Color(
                                              0xFFFFD467)
                                              :Colors.grey.withOpacity(0.5),size: 30)),
                                );
                              }),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
