import 'package:KABA/src/ui/customwidgets/performance_ui.dart';
import 'package:KABA/src/ui/screens/chat/ChatPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../contracts/transaction_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../../utils/_static_data/AppConfig.dart';
import '../../utils/_static_data/ImageAssets.dart';
import '../../utils/_static_data/Vectors.dart';
import '../screens/home/_home/InfoPage.dart';
import '../screens/home/me/abonnement/kaba_abonnements.dart';

Widget Header(BuildContext context){
  return Container(
    height: 80,
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: KColors.primaryColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: (){
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24), // reduce empty space around
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: IntrinsicWidth(
                    child: IntrinsicHeight(
                      child: PerformanceCard(
                        currentRating: 4.7,
                        reviewCount: 120,
                        speed: 5,
                        geolocationRespect: 5,
                        attitude: 4.5,
                        appearance: 4.3,
                      ),
                    ),
                  ),
                );
              },
            );


          },
          child: Container(
            margin: EdgeInsets.only(left: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFCF2A4E),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ]
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.boltLightning,color: Colors.orangeAccent,size: 14,),
                Text("4,7",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                Text("/5",style: TextStyle(color: Colors.orangeAccent,fontSize: 16,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        ),
        //abonnement
        Container(
          width: 170,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Kaba_abonnement(presenter: TransactionPresenter(
                      TransactionView()
                    ),)),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.subscriptions,color: Colors.white,),
                    Text("Abo.",style: TextStyle(color: Colors.white,fontSize: 12),)
                  ],
                ),
              ),
              Container(width: 1,height: 20,color: Colors.white,),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,color: Colors.white,),
                    Text("Chat",style: TextStyle(color: Colors.white,fontSize: 12),
              )])),
              Container(width: 1,height: 20,color: Colors.white,),
              GestureDetector(
                onTap: (){
                  showBottomContactSheet(context);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_outlined,color: Colors.white,),
                    Text("Call",style: TextStyle(color: Colors.white,fontSize: 12),)
                  ],
                ),
              ),
            ],
          ),
        )

      ],
    ),
  );
}
Future<void> _callCustomerCare()async {
//    Toast.show("call customer care", context);
  const url = "tel:+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
  }
}
_jumpToWhatsapp(BuildContext context) async {
  final link = WhatsAppUnilink(
    phoneNumber: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}',
    text: "${AppLocalizations.of(context)!.translate('i_have_an_inquiry')}",
  );
  await launch('$link');
}
showBottomContactSheet(BuildContext context) {
  showMaterialModalBottomSheet(
    backgroundColor: Colors.transparent,
    expand: false,
    context: context,
    builder: (context) => Container(
        width: 335,
        height: 155,
        margin: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
                width:double.infinity ,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
                child: Text("${AppLocalizations.of(context)!.translate('contact_our_customer_service')}",style: TextStyle(color: Colors.white,fontSize: 14))),
            InkWell(
              onTap: () => {_callCustomerCare()},
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "${AppLocalizations.of(context)!.translate('phone_call')}",
                          style: TextStyle(
                              fontSize: 14,
                              color: KColors.new_black,
                              fontWeight: FontWeight.w500)),
                      Icon(Icons.call, size: 20, color: KColors.primaryColor)
                    ]),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                color: KColors.new_gray,
                height: 1),
            InkWell(
              onTap: () => {_jumpToWhatsapp(context)},
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                          "${AppLocalizations.of(context)!.translate('whatsapp')}",
                          style: TextStyle(
                              fontSize: 14,
                              color: KColors.new_black,
                              fontWeight: FontWeight.w500)),
                      // Icon(Icons.call, size: 20, color: KColors.primaryColor)
                      Container(
                          width: 20,
                          height: 20,
                          child: Image.asset(ImageAssets.whatsapp)),
                    ]),
              ),
            ),
          ],
        )),
  );
}