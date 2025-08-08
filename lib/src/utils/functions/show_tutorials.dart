import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localizations/AppLocalizations.dart';
import '../../microservices/kaba_chine/core/constants.dart';

void showCertificationTutorial({required BuildContext context}){
  showDialog(context: context, builder: (BuildContext context){
    return Dialog(

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.white,
        child: Container(
          height: 300,
          width: MediaQuery.of(context).size.width*0.7,

          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: MediaQuery.of(context).size.height*0.30,

                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: KabaChineColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color:
                      Color(0xff3b5898), size: 30),
                      Text(
                        "${AppLocalizations.of(context)!.translate('certification_tutorial_text')}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  side: BorderSide(
                                    color: KabaChineColors.primary,
                                    width: 1.0,
                                  ),

                                ),
                              ),
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.translate('ok'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )),
                          TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                  side: BorderSide(
                                    color: KabaChineColors.primary,
                                    width: 1.0,
                                  ),

                                ),
                              ),
                              onPressed: ()async {
                                final uri = Uri.parse("https://www.linkedin.com/pulse/kaba-pr%C3%A9sente-sa-vignette-de-certification-qualit%C3%A9-72sne?utm_source=share&utm_medium=member_android&utm_campaign=share_via");
                                if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppLocalizations.of(context)!.translate('know_more'),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 20,
                  left: 30,
                  child: Image.asset("assets/images/png/start_certif.png",width: 30,)),
              Positioned(
                  top: 70,
                  right: 30,
                  child: Image.asset("assets/images/png/start_certif.png",width: 30,)),
              Positioned(
                top: 0,
                  child: Image.asset("assets/images/png/certif.png",width: 150,)),

            ],
          ),
        )
    );
  });
}