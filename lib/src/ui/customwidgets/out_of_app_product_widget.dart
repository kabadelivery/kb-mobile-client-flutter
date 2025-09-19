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
import '../../xrint.dart';

Widget OutOfAppProduct(
    BuildContext context,
    WidgetRef ref,
    int index,
    File image,
    String name,
    int price,
    int quantity)
{
  Size size = MediaQuery.of(context).size;
  xrint(size);
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 90,
            width: size.width*.7,
            padding:  EdgeInsets.symmetric(vertical: 0.0,horizontal: 15),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3)),
              ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //   Container(
                //                         height: 70,
                //                         width: 70,
                //                         decoration: BoxDecoration(
                //                             borderRadius: BorderRadius.circular(10),
                //                             image: image!=null?DecorationImage(
                //                                 image: FileImage(image),
                //                                 fit: BoxFit.cover
                //                             ):null,
                //                         )
                //
                //                       ),
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFFAE8EC)
                  ),
                  child: Text("${quantity}",style: TextStyle(fontSize: 15,color:KColors.primaryColor,fontWeight: FontWeight.bold),),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.length>10?name.substring(0,10)+"..":name,style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                    Text("${price.toInt()*quantity} FCFA",style: TextStyle(fontSize:14),),

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: (){

                        },
                        child: Text("-",style: TextStyle(fontSize: 20,color:Colors.black87,fontWeight: FontWeight.bold),)),
                    SizedBox(width: 10,),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:Border.all(width: .5,color:Colors.grey)
                      ),
                      alignment: Alignment.center,
                      child: Text(quantity.toString(),style: TextStyle(fontSize: 20,color:Colors.black87,fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: 10,),
                    InkWell(
                         onTap: (){

                         },
                        child: Text("+",style: TextStyle(fontSize: 20,color:Colors.black87,fontWeight: FontWeight.bold),)),
                  ],
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
                        CustomerModel customer = ref.watch(orderBillingStateProvider).customer!;
                        List<DeliveryAddressModel> order_address = ref.watch(locationStateProvider).selectedOrderAddress!;
                        DeliveryAddressModel shipping_adress =  ref.watch(locationStateProvider).selectedShippingAddress!;
                        var _selectedVoucher = ref.watch(voucherStateProvider).selectedVoucher;
                        var _usePoint = ref.watch(voucherStateProvider).usePoint;

                        outOfAppNotifier .setIsBillBuilt(false);
                        outOfAppNotifier.setShowLoading(true);
                        try{
                          await api.computeBillingAction(customer, order_address, formData, shipping_adress, _selectedVoucher!, _usePoint!).then((value){
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
                              msg: "🚨 "+AppLocalizations.of(context)!.translate("impossible_to_load_bill")+" 🚨");
                          outOfAppNotifier .setIsBillBuilt(false);
                          outOfAppNotifier.setShowLoading(false);
                        }
                      }else{
                        ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(null);
                      }
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(Icons.delete_outline_rounded,color: KColors.primaryColor,size: 25,),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }) ;
}


Widget OutOfAppProductItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    File image,
    String name,
    int price,
    int quantity)
{
  Size size = MediaQuery.of(context).size;
  xrint(size);
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: size.width*.7,
                  padding:  EdgeInsets.symmetric(vertical: 0.0,horizontal: 15),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Row(
                       children: [
                         Container(
                           height: 40,
                           width: 40,
                           alignment: Alignment.center,
                           decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(15),
                               color: Color(0xFFFAE8EC)
                           ),
                           child: Text("${quantity}",style: TextStyle(fontSize: 15,color:KColors.primaryColor,fontWeight: FontWeight.bold),),
                         ),
                         SizedBox(width: 5,),
                         Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(name.length>10?name.substring(0,10)+"..":name,style: TextStyle(fontSize:17,fontWeight: FontWeight.bold),),
                             Text("${price.toInt()} FCFA",style: TextStyle(fontSize:14),),
                           ],
                         ),
                       ],
                     ),
                      Text("${price.toInt()*quantity} FCFA",style: TextStyle(fontSize:14,fontWeight:FontWeight.bold,color:KColors.primaryColor),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }) ;
}
