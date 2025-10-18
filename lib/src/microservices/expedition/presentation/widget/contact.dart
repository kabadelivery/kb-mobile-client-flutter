import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

import '../../../../localizations/AppLocalizations.dart';
import '../../../../utils/_static_data/AppConfig.dart';
import '../../../../utils/_static_data/ImageAssets.dart';

showBottomContactSheet({required BuildContext context, required String number}) {
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
                width:double.infinity,
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
              onTap: () => {_callCustomerCare(number)},
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
              onTap: () => {_jumpToWhatsapp(context,number)},
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

Future<void> _callCustomerCare(String number) async {
//    Toast.show("call customer care", context);
  var url = "tel:$number";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
  }
}
_jumpToWhatsapp(context,String number) async {
  final link = WhatsAppUnilink(
    phoneNumber: '$number',
    text: "${AppLocalizations.of(context)!.translate('i_have_an_inquiry')}",
  );
  await launch('$link');
}