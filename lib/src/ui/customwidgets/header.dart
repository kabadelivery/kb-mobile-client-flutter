import 'package:KABA/src/ui/customwidgets/performance_ui.dart';
import 'package:KABA/src/ui/screens/chat/ChatPage.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../StateContainer.dart';
import '../../contracts/transaction_contract.dart';
import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../utils/_static_data/AppConfig.dart';
import '../../utils/_static_data/ImageAssets.dart';
import '../../utils/_static_data/Vectors.dart';
import '../../utils/functions/NotLoggedInPopUp.dart';
import '../screens/home/_home/InfoPage.dart';
import '../screens/home/me/abonnement/kaba_abonnements.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Map<String, dynamic>? performance;
  void getPerf()async{
    performance = await Utils.getAppPerformance();
    CustomerModel customerModel = await CustomerUtils.getCustomer();
   // debugPrint("CustomerModel token ${customerModel.token}");
    setState(() {});
  }
  @override void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    getPerf();
   return  Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 15),
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
       performance!=null?   GestureDetector(
            onTap: ()async{
              if(performance != null){
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
                            currentRating: performance!['final'],
                            reviewCount: performance!['count'],
                            speed: performance!['speed'],
                            geolocationRespect: performance!['geolocation'],
                            attitude: performance!['attitude'],
                            appearance: performance!['appearance'],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
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
                  Text("${performance!['final']}",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),),
                  Text("/5",style: TextStyle(color: Colors.orangeAccent,fontSize: 16,fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ):Container(height: 0, width: 0,),
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
                      Image.asset("assets/images/png/abo_white.png",width: 25,height: 25,),
                      Text("Abo.",style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                Container(width: 1,height: 20,color: Colors.white,),
                GestureDetector(
                    onTap: (){
                      if (StateContainer.of(context).loggingState == 0){
                        NotLoggedInPopUp(context);
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    token: '',
                                    receiverId: 1,
                                  )),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none, // allows the green dot to overflow
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 25,
                            ),
                            Positioned(
                              right: -2,
                              top: -5,
                              child: Container(
                                padding: EdgeInsets.all(1),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: Text("+1",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 10,color: KColors.primaryColor),)
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          "Chat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )


                ),
                Container(width: 1,height: 20,color: Colors.white,),
                GestureDetector(
                  onTap: (){
                    showBottomContactSheet(context);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_outlined,color: Colors.white,),
                      Text("Call",style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.bold),)
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