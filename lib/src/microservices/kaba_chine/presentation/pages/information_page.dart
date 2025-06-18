import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/utils.dart';
import '../widgets/user_infos_page_widgets.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
