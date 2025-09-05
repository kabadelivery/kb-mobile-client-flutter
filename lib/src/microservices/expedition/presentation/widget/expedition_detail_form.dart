import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils.dart';

class ExpeditionDetailForm extends StatefulWidget {
  const ExpeditionDetailForm({super.key});

  @override
  State<ExpeditionDetailForm> createState() => _ExpeditionDetailFormState();
}

class _ExpeditionDetailFormState extends State<ExpeditionDetailForm> {
  bool acceptedProhibitedItems = false;
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _packageContainer = TextEditingController();
  String firstImagePath = "";
  String secondImagePath = "";
  String thirdImagePath = "";
  bool kaba_fetch_the_package = false;
  bool deposit_of_the_package = false;
  bool positionChoosed=true;
  bool addressSavedChoosed=false;
  bool addNewAddress = false;
  DateTime? selectedDate = null;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 330,
      child: Column(
        children: [
          //Package description
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400,width: 0.5),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text('Description du colis',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                SizedBox(height: 10,),
                Text("Que contient votre colis? Fournir les détails précis",style: TextStyle(fontSize: 12,color: Colors.black87),),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _packageContainer,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                    ),
                    hintText: "Ex: Vêtements, chaussures, produits, cosmétiques, etc.",
                    hintStyle: TextStyle(fontSize: 12,color: Colors.grey.shade400),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Text('Articles interdits ? ',style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                    GestureDetector(child: Icon(Icons.info_outline_rounded,size: 17,color: KabaExpeditionColor.primary,)),
                  ],
                ),
                SizedBox(height: 5,),
                Container(
                  padding: EdgeInsets.only(left: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade400,width: 0.5)
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                      focusColor: KabaExpeditionColor.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      value: acceptedProhibitedItems, onChanged: (value){
                        setState(() {
                          acceptedProhibitedItems = !acceptedProhibitedItems;
                        });
                      }),
                      Text("J'ai lu et j'accepte la liste des articles interdits",style: TextStyle(fontSize: 11,color: Colors.black54),)
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Text("Quantité",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                    ),
                    hintText: "Ex: 3",
                    hintStyle: TextStyle(fontSize: 12,color: Colors.black87),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
          SizedBox(height: 15,),
          //Package pics
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400,width: 0.5),
            ),
            child: Column(
              children: [
                Text('Photos du colis (2 obligatoires)',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                SizedBox(height: 10,),
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: [
                   GestureDetector(
                     child: DottedBorder(
               options: RoundedRectDottedBorderOptions(
                 dashPattern: [10,6],
                 strokeWidth: 1,
                 color: Colors.black38,
                 radius: Radius.circular(10),
               ), child: Container(
                 height: 85,
                 width: 85,
                 child: firstImagePath!=null && firstImagePath.isEmpty?
                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Transform.rotate(
                               angle: 55,
                               child: Icon(Icons.logout,size: 30,color: Colors.black54,)),
                           Text("Obligatoire",style: TextStyle(fontSize: 11,color: Colors.black54,fontWeight:FontWeight.bold ),),
                         ],
                       ):
                   Container(
                     height: 85,
                     width: 85,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Colors.black.withOpacity(0.2)
                     ),
                     child: Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(firstImagePath),
                            fit: BoxFit.cover
                          )
                        ),
                     ),
                   )
                   ),),
                   ),
                   GestureDetector(
                     child: DottedBorder(
               options: RoundedRectDottedBorderOptions(
                 dashPattern: [10,6],
                 strokeWidth: 1,
                 color: Colors.black38,
                 radius: Radius.circular(10),
               ), child: Container(
                 height: 85,
                 width: 85,
                 child: secondImagePath!=null && secondImagePath.isEmpty?
                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Transform.rotate(
                               angle: 55,
                               child: Icon(Icons.logout,size: 30,color: Colors.black54,)),
                           Text("Obligatoire",style: TextStyle(fontSize: 11,color: Colors.black54,fontWeight:FontWeight.bold ),),
                         ],
                       ):
                   Container(
                     height: 85,
                     width: 85,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Colors.black.withOpacity(0.2)
                     ),
                     child: Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(firstImagePath),
                            fit: BoxFit.cover
                          )
                        ),
                     ),
                   )
                   ),),
                   ),
                   GestureDetector(
                     child: DottedBorder(
               options: RoundedRectDottedBorderOptions(
                 dashPattern: [10,6],
                 strokeWidth: 1,
                 color: Colors.black38,
                 radius: Radius.circular(10),
               ), child: Container(
                 height: 85,
                 width: 85,
                 child: thirdImagePath!=null && thirdImagePath.isEmpty?
                 Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                         children: [
                           Transform.rotate(
                               angle: 55,
                               child: Icon(Icons.logout,size: 30,color: Colors.black54,)),
                           Text("Obligatoire",style: TextStyle(fontSize: 11,color: Colors.black54,fontWeight:FontWeight.bold ),),
                         ],
                       ):
                   Container(
                     height: 85,
                     width: 85,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(10),
                       color: Colors.black.withOpacity(0.2)
                     ),
                     child: Container(
                        height: 85,
                        width: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(firstImagePath),
                            fit: BoxFit.cover
                          )
                        ),
                     ),
                   )
                   ),),
                   ),
                 ],
               )
              ],
            ),
          ),
          SizedBox(height: 15,),
          //Recipient address
          Container(
            width: 330,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400,width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adresse du destinataire',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
                SizedBox(height: 10,),
                Text("Ville",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                    ),
                    hintText: "Ex: Abidjan",
                    hintStyle: TextStyle(fontSize: 12,color: Colors.black87),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                  ),
                ),
                SizedBox(height: 10,),
                Text("Repères",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF3F3F5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFF3F3F5),width: 0.5)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: KabaExpeditionColor.primary,width: 1)
                    ),
                    hintText: "Ex: Près de l’Hôtel Labadi Beach, en face de...",
                    hintStyle: TextStyle(fontSize: 12,color: Colors.black87),
                    contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 10)
                  ),
                ),
                SizedBox(height: 5,),
                Text("Localisation",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                SizedBox(height: 5,),
                GestureDetector(
                  child: Container(
                    width:200,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,size: 20,color: KabaExpeditionColor.primary,),
                        SizedBox(width: 10,),
                        Text("Ajouter une addresse GPS",style: TextStyle(fontSize: 12,color: KabaExpeditionColor.primary),)
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  child: Container(
                    width:200,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.save_outlined,size: 20,color: KabaExpeditionColor.primary,),
                        SizedBox(width: 10,),
                        Text("Addresses enregistrées",style: TextStyle(fontSize: 12,color: KabaExpeditionColor.primary),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          //pickup options
          Container(
            width: 330,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400,width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Adresse de recupération',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaExpeditionColor.primary),),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Kaba recupère le colis ?",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                      Text("Service de récupération à domicile",style: TextStyle(fontSize: 11,color: Colors.black38),),
                    ],
                  ),
                  SizedBox(width: 10,),
                  //Toggle button
                  Switch(
                    thumbColor: MaterialStateProperty.all( kaba_fetch_the_package? KabaExpeditionColor.primary:Color(0xff48444e)),
                    activeTrackColor: KabaExpeditionColor.primary.withOpacity(0.3),

                    thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: kaba_fetch_the_package? KabaExpeditionColor.primary:Color(0xff48444e),size: 15,)),
                    trackColor: MaterialStateProperty.all( kaba_fetch_the_package? KabaExpeditionColor.primary.withOpacity(.2):Color(0xffe4dee7)),
                    padding: EdgeInsets.all(0),
                    value: kaba_fetch_the_package,
                    activeColor: KabaExpeditionColor.primary,
                    onChanged: (value){
                      setState(() {
                        kaba_fetch_the_package = value;
                        deposit_of_the_package=!kaba_fetch_the_package;
                      });
                    })
                ],
              ),
              kaba_fetch_the_package? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: KabaExpeditionColor.primary.withOpacity(.15),
                  border: Border.all(color: KabaExpeditionColor.primary,width: 0.5)

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("📍 Adresse de récupération",style: TextStyle(fontSize: 12,color:KabaExpeditionColor.primary,fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(height:10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: positionChoosed? KabaExpeditionColor.primary:Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_outlined,size: 20,color: !positionChoosed? KabaExpeditionColor.primary:Colors.white,),
                                Text("Position actuelle",style: TextStyle(fontSize: 11,color:!positionChoosed? KabaExpeditionColor.primary:Colors.white),)
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: addressSavedChoosed? KabaExpeditionColor.primary:Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save_outlined,size: 20,color: !addressSavedChoosed? KabaExpeditionColor.primary:Colors.white,),
                                Text("Adresses enregistrées",style: TextStyle(fontSize: 11,color:!addressSavedChoosed? KabaExpeditionColor.primary:Colors.white),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height:10),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: addNewAddress? KabaExpeditionColor.primary:Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: KabaExpeditionColor.primary.withOpacity(0.5),width: 0.5)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_circle_outline,size: 20,color: !addNewAddress? KabaExpeditionColor.primary:Colors.white,),
                            Text("Ajouter une nouvelle adresse",style: TextStyle(fontSize: 11,color:!addNewAddress? KabaExpeditionColor.primary:Colors.white),)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height:10),
                    Text("📅 Planification de la récupération",style: TextStyle(fontSize: 12,color:KabaExpeditionColor.primary,fontWeight: FontWeight.bold),),
                    SizedBox(height:10),
                    Text("Date de récupération",style: TextStyle(fontSize: 12,color:Colors.black87,fontWeight: FontWeight.bold),),
                    SizedBox(height:10),
                    GestureDetector(
                      child: Container(
                        width: 330,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:selectedDate==null? Colors.white: KabaExpeditionColor.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedDate==null?"Sélectionnez une date":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",style: TextStyle(fontSize: 12,color:selectedDate==null? Colors.black54:Colors.white)),
                            Icon(Icons.calendar_month,color:selectedDate==null? Colors.grey:Colors.white,size: 17,)
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height:10),
                    GestureDetector(
                      child: Container(
                        width: 330,
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:selectedDate==null? Colors.white: KabaExpeditionColor.primary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedDate==null?"Sélectionnez un créneau":"${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",style: TextStyle(fontSize: 12,color:selectedDate==null? Colors.black54:Colors.white)),
                            Icon(Icons.alarm,color:selectedDate==null? Colors.grey:Colors.white,size: 17,)
                          ],
                        ),
                      ),
                    )
                  ]
                ),
              ):SizedBox(height: 0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Vous déposez le colis ?",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),
                      Text("Déposer à nos bureaux Kaba",style: TextStyle(fontSize: 11,color: Colors.black38),),
                    ],
                  ),
                  SizedBox(width: 10,),
                  //Toggle button
                  Switch(
                    thumbColor: MaterialStateProperty.all( deposit_of_the_package? KabaExpeditionColor.primary:Color(0xff48444e)),
                    activeTrackColor: KabaExpeditionColor.primary.withOpacity(0.3),

                    thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: deposit_of_the_package? KabaExpeditionColor.primary:Color(0xff48444e),size: 15,)),
                    trackColor: MaterialStateProperty.all( deposit_of_the_package? KabaExpeditionColor.primary.withOpacity(.2):Color(0xffe4dee7)),
                    padding: EdgeInsets.all(0),
                    value: deposit_of_the_package,
                    activeColor: KabaExpeditionColor.primary,
                    onChanged: (value){
                      setState(() {
                        deposit_of_the_package = value;
                        kaba_fetch_the_package =!deposit_of_the_package;
                      });
                    }),

                ],
              ),
              deposit_of_the_package?
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: KabaExpeditionColor.primary.withOpacity(.15),
                      border: Border.all(color: KabaExpeditionColor.primary,width: 0.5)

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,size: 20,color: KabaExpeditionColor.primary,),
                          SizedBox(width: 10,),
                          Text("Bureau Kaba",style: TextStyle(fontSize: 12,color: Colors.black87,fontWeight: FontWeight.bold),),

                        ],
                      ),
                      SizedBox(height: 10,),
                      Text("319 Rue AGP, Agbalépédo, Lomé TOGO",style: TextStyle(fontSize: 13,color: Colors.black54,fontWeight: FontWeight.w400),),
                      SizedBox(height: 10,),
                      MaterialButton(
                        onPressed: (){
                          Uri googleMapsUrl = Uri.parse('https://maps.app.goo.gl/NjLzrtw41wevzjneA');
                          launchUrl(googleMapsUrl);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)
                        ),
                        elevation: 0,
                        padding: EdgeInsets.all(0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Color(0xFFCC1E44),
                                    Color(0xFFB71B3E),
                                    Color(0xFFA11738)
                                  ]
                                )
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.map_outlined,size: 17,color: Colors.white,),
                                  SizedBox(width: 10,),
                                  Text("Voir sur Google Maps",style: TextStyle(fontSize: 12,color: Colors.white,fontWeight: FontWeight.bold),),
                                  ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Text("Ouvert : Lundi - Samedi 08h-18h ",style: TextStyle(fontSize:12,color:KabaExpeditionColor.primary),),

                    ],
                  ),
                ):SizedBox(height: 0,),
              ]
            )
          ),
          //continuer

        ],
    )
    );
  }
}
