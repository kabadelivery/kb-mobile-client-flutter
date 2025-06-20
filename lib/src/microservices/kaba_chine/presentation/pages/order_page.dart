import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/utils.dart';
import '../../domain/tarif/shipping_entity.dart';
import '../widgets/office.dart';
import '../widgets/package_form_info.dart';

class KabaChineOrderPage extends StatefulWidget {
  const KabaChineOrderPage({super.key});

  @override
  State<KabaChineOrderPage> createState() => _KabaChineOrderPageState();
}

class _KabaChineOrderPageState extends State<KabaChineOrderPage> {

  String customercode = "TG-123456789";
  List<ShippingEntity> shipping_offices = [
    ShippingEntity(departure: "GuangZhou", destination: "Agbalépédogan",),
  ];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: size.width,
            height: 170,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  KabaChineColors.primary,
                  KabaChineColors.primary_darker,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 20,),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: KabaChineColors.card.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(Icons.arrow_back_sharp,size: 20,color: KabaChineColors.card,),
                    ),
                    Container()
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Demande de livraison",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 23),),
                    SizedBox(height: 10),
                    Text("Votre code client : $customercode",style: TextStyle(color: Colors.white,fontSize: 14),)
                  ],
                ),

              ],
            )
          ),
          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size.width,
              height: 90,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 2),
                  ),
                ],
                color:  Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(width: 4,color: KabaChineColors.primary)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code client"),
                    Text("${customercode}",style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),),
                    Text("Ce code sera utilisé pour identifier votre colis.",style: TextStyle(color: Colors.black54,fontSize: 12),)
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          OfficesWidget(context: context,shipping_offices:[ShippingEntity(departure: "GuangZhou", destination: "Agbalépédogan")]),
          SizedBox(height: 10),
          ExpeditionModes(context: context),
          SizedBox(height: 10,),
          PackageFormInfo(context:context)
                  ]
    )
    );
  }
}
