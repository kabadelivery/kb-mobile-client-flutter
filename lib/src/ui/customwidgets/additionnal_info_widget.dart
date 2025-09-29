import 'dart:io';

import 'package:KABA/src/state_management/out_of_app_order/additionnal_info_state.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../localizations/AppLocalizations.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../state_management/out_of_app_order/products_state.dart';
import '../../utils/functions/OutOfAppOrder/imagePicker.dart';
import '../../utils/functions/permissions.dart';
import '../../xrint.dart';

Widget AdditionnalInfo(BuildContext context, WidgetRef ref, int type, String text) {
  TextEditingController _infoController = TextEditingController();
  final outOfAppState = ref.watch(outOfAppScreenStateProvier);
  _infoController.text = text;
  _infoController.selection = TextSelection.fromPosition(
    TextPosition(offset:text.length),
  );
  return Consumer(
    builder: (context, ref, child) {
      return  type==2?
      TextField(
        controller: _infoController,
        onChanged: (value) {
          ref.read(additionnalInfoProvider.notifier).setAdditionnalAddressInfo(value);
          _infoController.text = ref.watch(additionnalInfoProvider).additionnal_address_info;
        },
        decoration: InputDecoration(
          hintText: "Ex : Pharmacie Vigueur, en face de...",
          filled: true,
          fillColor: const Color(0xFFF2F3F4),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          color: Colors.grey.shade500 ,
        ),
      ):
      Column(
        children: [
          Container(

            decoration: BoxDecoration(
              color: Color(0x42d2d2d2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
              TextField(
                controller: _infoController,
                maxLines: 4,
                onChanged: (value) {
                    ref.read(additionnalInfoProvider.notifier).setAdditionnalInfo(value);
                    _infoController.text = ref.watch(additionnalInfoProvider).additionnal_info;
                },
                style: TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelStyle: TextStyle(fontSize: 12),
                  labelText: "${AppLocalizations.of(context)!.translate(
                      type == 1
                          ?(outOfAppState.order_type!=5&&outOfAppState.order_type!=6?'additional_info':'package_info')
                          : type == 2
                          ? 'address_additionnal_info'
                          : 'additional_info')}...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      );
    },
  );
}


Widget AdditionnalInfoImage(BuildContext context, WidgetRef ref) {


    Size size = MediaQuery.of(context).size;
    final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
    final File? selectedImage = ref.watch(additionnalInfoProvider).image;
    return GestureDetector(

              onTap:outOfAppScreenState.showLoading==false? ()async{
                 if(Platform.isAndroid){
                   try{
                       await pickImageAndroid(context).then((value){
                         if (value != null) {
                           ref.read(additionnalInfoProvider.notifier).setImage(value);
                         } else {
                           debugPrint("No image picked or image too large.");
                           // Optionally show a SnackBar or handle cancellation here
                         }   });
                   }catch(e){
                     xrint("##Error in image picking, out of app order## $e");
                   }
                 }else{
                   try{
                     bool granted = await requestCameraAndGalleryPermissions();
                     if (granted) {
                       await pickImageIOS(context).then((value){
                         ref.read(additionnalInfoProvider.notifier).setImage(value!);
                       });
                       print("Camera permission granted!");
                     } else {
                       print("Camera permission denied.");
                     }
                   }catch(e){
                     xrint("##Error in image picking, out of app order## $e");
                   }
                 }
              }:null,
            child: Container(
  height: 70,

  alignment: Alignment.center,
  decoration: BoxDecoration(
    color: Color.fromARGB(47, 202, 160, 67),
    borderRadius: BorderRadius.circular(5),
    image: selectedImage != null
        ? DecorationImage(
            image: FileImage(ref.watch(additionnalInfoProvider).image!),
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Dark overlay
      if (selectedImage != null)
        Container(
          height: 70,
          width: size.width * 0.92,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
            borderRadius: BorderRadius.circular(5),
          ),
        ),

      // Icon and Text
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BouncingWidget(
            duration: Duration(milliseconds: 400),
            scaleFactor: 2,
            onPressed: () {  },
            child: Icon(Icons.camera_alt, color:ref.watch(additionnalInfoProvider).image==null? Color.fromARGB(199, 165, 115, 23):Color.fromARGB(255, 255, 255, 255)),
          ),
          SizedBox(height: 5),
          Text(

            "${AppLocalizations.of(context)!.translate(outOfAppScreenState.order_type!=5&&outOfAppScreenState.order_type!=6?'choose_additionnal_image':'choose_an_image')}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color:ref.watch(additionnalInfoProvider).image==null? Color.fromARGB(199, 165, 115, 23):Color.fromARGB(197, 255, 255, 255),
            ),
          ),
        ],
      ),
    ],
  ),
),
  
);
      
}

