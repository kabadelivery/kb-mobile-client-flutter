import 'dart:io';

import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/order_billing_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../localizations/AppLocalizations.dart';
import '../../models/CustomerModel.dart';
import '../../models/DeliveryAddressModel.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/products_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/_static_data/KTheme.dart';

Widget OutOfAppProduct(
    BuildContext context,
    WidgetRef ref,
    int index,
    File image,
    String name,
    int price,
    int quantity){
  Size size = MediaQuery.of(context).size;
  print(size);
  bool isDeleted= false;
  return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500),
      builder: (context,double value,child){
    return Opacity(
      opacity: value,
    child: Transform.scale(
        scale: value,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: size.width*.85,
            decoration: BoxDecoration(
                color: Color(0x42d2d2d2),
                borderRadius: BorderRadius.circular(5)
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment:size.width>600? MainAxisAlignment.spaceBetween: MainAxisAlignment.spaceEvenly,
                children: [
                  //image
                  Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: image!=null?DecorationImage(
                                image: FileImage(image),
                                fit: BoxFit.cover
                            ):null,
                        )

                      ),
                      SizedBox(width: 10,),
                      //Name
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name.length>10?name.substring(0,10)+"..":name,style: TextStyle(fontSize: size.width>700?15:12),),
                          Text("${price.toInt()}x${quantity}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: size.width>700?15:12),),

                        ],
                      ),

                    ],
                  ),
                   Container(

                    height: size.width>700?40:30,
                    decoration: BoxDecoration(
                      color: Color(0xfff0dbe1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text("${(price*quantity).toInt()} FCFA",style: TextStyle(fontSize:size.width>700?15:12,color: KColors.primaryColor,fontWeight: FontWeight.bold),),
                    ),
                  )
                ],
              ),
            ),
          ),
      
          GestureDetector(
            onTap: ()async{
              var outOfAppNotifier =ref.read(outOfAppScreenStateProvier.notifier);
              ref.read(productListProvider.notifier).removeProduct(index);
             if(ref.watch(locationStateProvider).is_shipping_address_picked==true){
               if(ref.watch(productListProvider).isNotEmpty){
                 var foods = ref.watch(productListProvider);
                 List<Map<String, dynamic>> formData = [];

                 for (int i = 0; i < foods.length; i++) {
                   formData.add(
                       { 'name': foods[i]['name'],
                         'price': foods[i]['price'].toString(),
                         'quantity': foods[i]['quantity'].toString(),
                         'image': ""
                       }
                   );
                 }
                 OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                 CustomerModel customer = ref.watch(orderBillingStateProvider).customer;
                 List<DeliveryAddressModel> order_address = ref.watch(locationStateProvider).selectedOrderAddress;
                  DeliveryAddressModel shipping_adress =  ref.watch(locationStateProvider).selectedShippingAddress;
                 var _selectedVoucher = ref.watch(voucherStateProvider).selectedVoucher;
                 var _usePoint = ref.watch(voucherStateProvider).usePoint;

                 outOfAppNotifier .setIsBillBuilt(false);
                 outOfAppNotifier.setShowLoading(true);
                  try{
                 await api.computeBillingAction(customer, order_address, formData, shipping_adress, _selectedVoucher, _usePoint).then((value){
                   ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(value);
                   outOfAppNotifier .setIsBillBuilt(true);
                   outOfAppNotifier.setShowLoading(false);
                 });
                  }catch(e){
                    Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context).translate("impossible_to_load_bill")+" 🚨");
                    outOfAppNotifier .setIsBillBuilt(false);
                    outOfAppNotifier.setShowLoading(false);
                  }
               }else{
                 ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
               }
             }
            },
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.circular(5)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.delete,color: Colors.white,size: 15,),
              ),
            ),
          )
        ],
      ),
    ),
    );
  }) ;
}