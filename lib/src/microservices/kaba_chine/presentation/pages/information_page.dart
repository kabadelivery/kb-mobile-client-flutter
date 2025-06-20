import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils.dart';
import '../../domain/tarif/shipping_entity.dart';
import '../../domain/tarif/tarif_entity.dart';
import '../widgets/contact_assistance.dart';
import '../widgets/tarif.dart';
import '../widgets/user_infos_page_widgets.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {

  TarifEntity boatRate=TarifEntity();
  TarifEntity planeRate=TarifEntity();
  ShippingEntity shipping =ShippingEntity();
  @override
  Widget build(BuildContext context) {
    boatRate.duration = 45;
    boatRate.price = 25000;
    boatRate.type = Tariftype.boat.value;
    planeRate.duration = 21;
    planeRate.price = 45000;
    planeRate.type = Tariftype.plane.value;
    ShippingEntity shipping = ShippingEntity(
      departure: "GuangZhou",
      destination: "Lomé",
    );
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("KABA Chine",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 23),),
                    SizedBox(height: 10),
                    Text("Service de livraison international",style: TextStyle(color: Colors.white,fontSize: 14),)
                  ],
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: KabaChineColors.card.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(Icons.share,size: 20,color: KabaChineColors.card,),
                )
              ],
            ),
          ),
          SizedBox(height: 10),
          userIdInfo(
            context: context,
            userId: "TG-1234567890",
          ),
          userProfileInfo(context: context,customer_code: "TG-1234567890",name:"Ben Boris",tel: "+225 01 02 03 04"),
          tarifExpeditionWidget(context: context,
            shipping: shipping,
            boatRate: boatRate,
            planeRate: planeRate, ),
          contactAssitanceListWidget(
            context: context,
          ),
        ],
      ),
    );
  }
}
