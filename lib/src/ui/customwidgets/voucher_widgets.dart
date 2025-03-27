import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../localizations/AppLocalizations.dart';
import '../../models/OrderBillConfiguration.dart';
import '../../models/VoucherModel.dart';
import '../../resources/out_of_app_order_api.dart';
import '../../state_management/out_of_app_order/location_state.dart';
import '../../state_management/out_of_app_order/order_billing_state.dart';
import '../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../state_management/out_of_app_order/products_state.dart';
import '../../state_management/out_of_app_order/voucher_state.dart';
import '../../utils/_static_data/KTheme.dart';
import '../../utils/functions/CustomerUtils.dart';
import '../../utils/functions/OutOfAppOrder/VoucherPicker.dart';
import 'MyVoucherMiniWidget.dart';

Widget BuildCouponSpace(BuildContext context, WidgetRef ref) {

  return Consumer(builder: (context,ref,child){
    final voucherState = ref.watch(voucherStateProvider);
    final voucherNotifier = ref.read(voucherStateProvider.notifier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
    final locationState= ref.watch(locationStateProvider);
    final locationNotifier= ref.read(locationStateProvider.notifier);
    final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    final productState = ref.watch(productListProvider);
    VoucherModel voucherSelected = voucherState.selectedVoucher;

    print('VoucherModeler $voucherSelected');
    if (voucherSelected == null) {
      return Column(children: <Widget>[
        SizedBox(height: 10),
        /* do you have a voucher you want to use ? */
        InkWell(
          onTap: ()async {
            try{
              VoucherModel voucher = await SelectVoucher(context, ref, false, null);
              await getBillingForVoucher(context,ref,voucher).then((value)async {
                outOfAppNotifier.setIsBillBuilt(true);
                outOfAppNotifier.setShowLoading(false);
                orderBillingNotifier.setOrderBillConfiguration(value);

              });
            }catch(e){
              print("ERROR getBillingForVoucher : $e");
            }

          },
          child: Shimmer(
            duration: Duration(seconds: 2),
            //Default value
            color: Colors.white,
            //Default value
            enabled: true,
            //Default value
            direction: ShimmerDirection.fromLTRB(),
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding:
                EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [KColors.primaryYellowColor, Colors.yellow]),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                /* please choose a voucher. */
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.add, color: KColors.white),
                              onPressed: ()async {
                                VoucherModel voucher = await SelectVoucher(context, ref, false, null);
                                OrderBillConfiguration orderBillConfiguration = await getBillingForVoucher(context,ref,voucher);

                                orderBillingNotifier.setOrderBillConfiguration(orderBillConfiguration);
                                outOfAppNotifier.setIsBillBuilt(true);
                                outOfAppNotifier.setShowLoading(false);
                              },
                          ),
                          IconButton(
                              icon: Icon(FontAwesomeIcons.ticketAlt,
                                  color: Colors.white),
                              onPressed: ()async {
                                VoucherModel voucher = await SelectVoucher(context, ref, false, null);
                                OrderBillConfiguration orderBillConfiguration = await getBillingForVoucher(context,ref,voucher);

                                orderBillingNotifier.setOrderBillConfiguration(orderBillConfiguration);
                                outOfAppNotifier.setIsBillBuilt(true);
                                outOfAppNotifier.setShowLoading(false);
                              },
                          )
                        ],
                      ),
                      Text(
                          "${AppLocalizations.of(context).translate('add_coupon')}",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ])),
          ),
        ),
        _buildEligibleVoucher(
            context,
            ref,
            null)
      ]);
    }
    else {
      OrderBillConfiguration orderBillConfiguration;
//   _selectedVoucher
      return Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: MyVoucherMiniWidget(
                      voucher: voucherState.selectedVoucher, isForOrderConfirmation: true)),
              Positioned(
                  right: 10,
                  top: 0,
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.blue,
//                borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: IconButton(
                            icon: Icon(Icons.delete_forever,
                                color: Colors.white, size: 20),
                            onPressed: ()async  {
                              List<Map<String, dynamic>> formData = [];

                              for (int i = 0; i < productState.length; i++) {
                                formData.add(
                                    { 'name': productState[i]['name'],
                                      'price': productState[i]['price'].toString(),
                                      'quantity': productState[i]['quantity'].toString(),
                                      'image': ""
                                    }
                                );
                              }
                              outOfAppNotifier.setIsBillBuilt(false);
                              outOfAppNotifier.setShowLoading(true);
                              OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
                          try
                              {await api.computeBillingAction(
                                  orderBillingState.customer,
                                  locationState.selectedOrderAddress,
                                  formData,
                                  locationState.selectedShippingAddress,
                                  null,
                                  false).then((value){
                                voucherNotifier.state.selectedVoucher=null;
                                outOfAppNotifier.setIsBillBuilt(true);
                                outOfAppNotifier.setShowLoading(false);
                                orderBillingNotifier.setOrderBillConfiguration(value);

                              });
                              }catch(e){
                            Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context).translate("impossible_to_load_bill")+" 🚨");
                                outOfAppNotifier.setIsBillBuilt(false);
                                outOfAppNotifier.setShowLoading(false);
                                        }
                            }
                            ),
                      ),
                    ),
                  )),
            ],
          ),
          _buildEligibleVoucher(context,ref,orderBillConfiguration)
        ],
      );
    }
  });

}

Widget   _buildEligibleVoucher(BuildContext context, WidgetRef ref,OrderBillConfiguration orderBillConfiguration) {

  List<VoucherModel> eligible_vouchers = orderBillConfiguration!=null?orderBillConfiguration.eligible_vouchers:[];
  if(orderBillConfiguration!=null){
    ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(orderBillConfiguration);
    var outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    outOfAppNotifier.setIsBillBuilt(true);
    outOfAppNotifier.setShowLoading(false);
  }
  return Consumer(builder: (context,ref,child){
    final voucherState = ref.watch(voucherStateProvider);
    final voucherNotifier = ref.read(voucherStateProvider.notifier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
    final locationState= ref.watch(locationStateProvider);
    final locationNotifier= ref.read(locationStateProvider.notifier);
    final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    final productState = ref.watch(productListProvider);

    if (eligible_vouchers == null)
      return Container();
    else
      return Container(
        color: KColors.new_gray,
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Column(
            children: List.generate(eligible_vouchers.length, (index) {
              if (eligible_vouchers[index].id == voucherState.selectedVoucher?.id ||
                  eligible_vouchers[index].use_count -
                      eligible_vouchers[index].already_used_count ==
                      0)
                return Container(
                  /* padding: EdgeInsets.only(
                    right: 10,
                    left: 10,
                    top: index == 0 ? 10 : 0,
                    bottom: index == eligible_vouchers.length - 1 ? 10 : 0)*/
                );
              return Container(
                padding: EdgeInsets.only(
                    right: 10,
                    left: 10,
                    top: index == 0 ? 10 : 5,
                    bottom: index == eligible_vouchers.length - 1 ? 10 : 5),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                  child: Text(
                                    "${eligible_vouchers[index].value} ${eligible_vouchers[index].type == 1 ? "F" : "%"} OFF",
                                    style: TextStyle(
                                        color: KColors.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                      color: KColors.primaryColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(30))),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                  "${eligible_vouchers[index].type == 1 ? "${AppLocalizations.of(context).translate('voucher_type_shop')}" : (eligible_vouchers[index].type == 2 ? "${AppLocalizations.of(context).translate('voucher_type_delivery')}" : "${AppLocalizations.of(context).translate('voucher_type_all')}")}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: KColors.new_black))
                            ]),
                            SizedBox(height: 5),
                            Text(eligible_vouchers[index].trade_name,
                                style: TextStyle(color: Colors.grey, fontSize: 12))
                          ]),
                      GestureDetector(
                        onTap: () async{
                          VoucherModel voucher = await SelectVoucher(context,ref,true,eligible_vouchers[index]);
                          OrderBillConfiguration orderBillConfiguration = await getBillingForVoucher(context,ref,voucher);

                          ref.read(orderBillingStateProvider.notifier).setOrderBillConfiguration(orderBillConfiguration);
                          outOfAppNotifier.setIsBillBuilt(true);
                          outOfAppNotifier.setShowLoading(false);
                        },
                        child: Container(
                          child: Text(
                              "${AppLocalizations.of(context).translate('voucher_use')}",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: KColors.primaryColor,
                                  fontWeight: FontWeight.w600)),
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              color: KColors.primaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      )
                    ]),
              );
            })),
      );
  });

}

