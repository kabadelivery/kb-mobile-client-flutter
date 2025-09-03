import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                Text('Description du colis',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaChineColors.primary),),
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
                      borderSide: BorderSide(color: KabaChineColors.primary,width: 1)
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
                    GestureDetector(child: Icon(Icons.info_outline_rounded,size: 17,color: KabaChineColors.primary,)),
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
                      focusColor: KabaChineColors.primary,
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
                      borderSide: BorderSide(color: KabaChineColors.primary,width: 1)
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
                Text('Photos du colis (2 obligatoires)',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaChineColors.primary),),
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
                Text('Adresse du destinataire',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaChineColors.primary),),
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
                      borderSide: BorderSide(color: KabaChineColors.primary,width: 1)
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
                      borderSide: BorderSide(color: KabaChineColors.primary,width: 1)
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
                      border: Border.all(color: KabaChineColors.primary.withOpacity(0.5),width: 0.5)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,size: 20,color: KabaChineColors.primary,),
                        SizedBox(width: 10,),
                        Text("Ajouter une addresse GPS",style: TextStyle(fontSize: 12,color: KabaChineColors.primary),)
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
                      border: Border.all(color: KabaChineColors.primary.withOpacity(0.5),width: 0.5)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.save_outlined,size: 20,color: KabaChineColors.primary,),
                        SizedBox(width: 10,),
                        Text("Addresses enregistrées",style: TextStyle(fontSize: 12,color: KabaChineColors.primary),)
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
              Text('Adresse de recupération',style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold,color: KabaChineColors.primary),),
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
                    thumbColor: MaterialStateProperty.all( kaba_fetch_the_package? KabaChineColors.primary:Color(0xff48444e)),
                    activeTrackColor: KabaChineColors.primary.withOpacity(0.3),

                    thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: kaba_fetch_the_package? KabaChineColors.primary:Color(0xff48444e),size: 15,)),
                    trackColor: MaterialStateProperty.all( kaba_fetch_the_package? KabaChineColors.primary.withOpacity(.2):Color(0xffe4dee7)),
                    padding: EdgeInsets.all(0),
                    value: kaba_fetch_the_package,
                    activeColor: KabaChineColors.primary,
                    onChanged: (value){
                      setState(() {
                        kaba_fetch_the_package = value;
                      });
                    })
                ],
              ),
              kaba_fetch_the_package? Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: KabaChineColors.primary.withOpacity(.15),
                  border: Border.all(color: KabaChineColors.primary,width: 0.5)
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
                    thumbColor: MaterialStateProperty.all( deposit_of_the_package? KabaChineColors.primary:Color(0xff48444e)),
                    activeTrackColor: KabaChineColors.primary.withOpacity(0.3),

                    thumbIcon: MaterialStateProperty.all(Icon(Icons.circle,color: deposit_of_the_package? KabaChineColors.primary:Color(0xff48444e),size: 15,)),
                    trackColor: MaterialStateProperty.all( deposit_of_the_package? KabaChineColors.primary.withOpacity(.2):Color(0xffe4dee7)),
                    padding: EdgeInsets.all(0),
                    value: deposit_of_the_package,
                    activeColor: KabaChineColors.primary,
                    onChanged: (value){
                      setState(() {
                        deposit_of_the_package = value;
                      });
                    })
                ],
              )
              ]
            )
          ),
          //continuer

        ],
    )
    );
  }
}
