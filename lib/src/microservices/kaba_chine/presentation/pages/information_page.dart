import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../ui/customwidgets/MyLoadingProgressWidget.dart';
import '../../core/utils.dart';
import '../../domain/tarif/shipping_entity.dart';
import '../../domain/tarif/tarif_entity.dart';
import '../../domain/user/user_entity.dart';
import '../bloc/information/information_bloc.dart';
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
  UserEntity user = UserEntity();
  bool isLoading= true;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<InformationBloc>(context).add(getInfosEvent());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<InformationBloc, InformationState>(
   listener: (context, state) {
       if(state is getInfosState){
       user = state.user;
       boatRate = state.bookTarif;
       planeRate = state.planeTarif;
       shipping = ShippingEntity(
         departure: "GuangZhou",
         destination: "Lomé",
       );
       isLoading = false;
     }
  },
  builder: (context, state) {
    return
    SingleChildScrollView(
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
                GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: KabaChineColors.card.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(Icons.arrow_back_sharp,size: 20,color: KabaChineColors.card,),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          isLoading? Center(child: MyLoadingProgressWidget()):Column(
            children: [
              userIdInfo(
                context: context,
                userId: user.customer_code??"TG-XXXXXXX",
              ),
              userProfileInfo(context: context,
                  customer_code: user.customer_code??"TG-XXXXXXX",
                  name:user.name?? "",
                  tel: user.phone_number??"XXXXXXX"),
              tarifExpeditionWidget(context: context,
                shipping: shipping,
                boatRate: boatRate,
                planeRate: planeRate, ),
              contactAssitanceListWidget(
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  },
);
  }
}
