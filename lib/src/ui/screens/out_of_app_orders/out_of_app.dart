import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../StateContainer.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/VoucherModel.dart';
import '../../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../../utils/functions/OutOfAppOrder/launchOrder.dart';
import '../../../utils/functions/Utils.dart';
import '../../customwidgets/BouncingWidget.dart';
import '../../customwidgets/MyLoadingProgressWidget.dart';
import '../../customwidgets/additionnal_info_widget.dart';
import '../../customwidgets/address_additionnal_info_widget.dart';
import '../../customwidgets/billing_widget.dart';
import '../../customwidgets/choose_locations_widget.dart';
import '../../customwidgets/out_of_app_product_form_widget.dart';
import '../../customwidgets/out_of_app_product_widget.dart';
import '../../customwidgets/voucher_widgets.dart';


class OutOfAppOrderPage extends ConsumerWidget  {
  static var routeName = "/OutOfAppOrderPage";
  int shipping_address_type=1;
  int order_address_type=2;
  int simple_additionnal_info_type =1;
  int address_additionnal_info_type=2;
  int out_of_app_order_type=3;
  int out_of_app_order_type_without_address=4;
  GlobalKey poweredByKey = GlobalKey();
  void showOutOfAppProductForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: OutOfAppProductForm(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    Size size = MediaQuery.of(context).size;
    final products = ref.watch(productListProvider);
    final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final locationState = ref.watch(locationStateProvider);
    final locationNotifier = ref.read(locationStateProvider.notifier);
    final voucherState = ref.watch(voucherStateProvider);
    final additionnalInfoState = ref.watch(additionnalInfoProvider);
    print("voucherState ${voucherState.selectedVoucher}");
    print("isBillBuilt ${locationState.selectedOrderAddress}");
    return  Scaffold(
        appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        centerTitle: true,
        title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
        Utils.capitalize(
        "${AppLocalizations.of(context).translate('out_of_app_order')}"),
    style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white)),
    ],
    ),
    ),
    body:outOfAppScreenState.isPayAtDeliveryLoading==true?
    Center(child: MyLoadingProgressWidget(),)
    :Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: size.width,
                height: 105.0*products.length,
                child:
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context,index){
                  Map<String,dynamic> product = products[index];
                  if(products.length!=0){
                      return Container(
                          margin: EdgeInsets.only(bottom: 15),
                          child: OutOfAppProduct(
                              context,
                              ref,
                              index,
                              product['image'],
                              product['name'],
                              product['price'],
                              product['quantity']));
                  }
                  else{
                    return Text('Aucun produit');
                  }
                }
                )
            ),

            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: (){
                showOutOfAppProductForm(context);
              },
              child:  Container(

                decoration: BoxDecoration(
                  color: KColors.primaryColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child:Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("${AppLocalizations.of(context).translate('add_product')}"
                  ,style:TextStyle(color: Colors.white)
                  ),
                )
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AdditionnalInfo(context,ref,simple_additionnal_info_type,additionnalInfoState.additionnal_info),
            SizedBox(height: 10,),
            outOfAppScreenState.isBillBuilt==true &&
            outOfAppScreenState.showLoading==false?
            ShowBilling(context,orderBillingState.orderBillConfiguration):
            outOfAppScreenState.showLoading==true?
            MyLoadingProgressWidget()
                :Container()
            ,
            products.isNotEmpty && outOfAppScreenState.showLoading==false?
            Column(
              children: [
                SizedBox(height: 10,),
                locationState.selectedShippingAddress!=null &&  outOfAppScreenState.isBillBuilt==true?
                Column(
                  children: [
                    Text(
                      "${AppLocalizations.of(context).translate('shipping_address')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: KColors.new_black)),
                    BuildShippingAddress(context,ref,locationState.selectedShippingAddress),

                  ],
                ):
                ChooseShippingAddress(context,ref,shipping_address_type,poweredByKey,shipping_address_type),
                SizedBox(height: 10,),
                locationState.is_shipping_address_picked==true &&  (locationState.selectedOrderAddress==null)?
                Column(
                  children: [
                    ChooseShippingAddress(context,ref,order_address_type,poweredByKey,order_address_type),
                    SizedBox(height: 20,),
                    additionnalInfoState.can_add_address_info==false?
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${AppLocalizations.of(context).translate('add_address_additionnal_info')}",
                            style: TextStyle(

                                fontSize: 16,
                                color: Colors.grey.shade700)),
                        SizedBox(height: 10,),
                        CanAddAdditionnInfo(context,ref),
                      ],
                    ):
                    AdditionnalInfo(context,ref,address_additionnal_info_type,additionnalInfoState.additionnal_address_info),
                    SizedBox(height: 10,),
                  ],
                ):Container(),
                locationState.is_shipping_address_picked==true &&(locationState.selectedOrderAddress!=null)?
                Column(
                  children: [
                    Text(
                        "${AppLocalizations.of(context).translate('order_address')}",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: KColors.new_black)),
                    BuildOrderAddress(context,ref,locationState.selectedOrderAddress[0]),

                  ],
                ):Container()
                ,
              ],
            ):Container(),
            SizedBox(key: poweredByKey, height: 25),
            outOfAppScreenState.isBillBuilt==true &&
                outOfAppScreenState.showLoading==false?BuildCouponSpace(context,ref):Container(),
            SizedBox(height: 20,),
            outOfAppScreenState.isBillBuilt==true &&
                outOfAppScreenState.showLoading==false?
            Container(
              decoration: BoxDecoration(
                  color: KColors.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
              child: InkWell(
                onTap: () {
                  int type_of_order = 4; // Default

                  List<DeliveryAddressModel> adrs = [];

                  if (locationState.selectedOrderAddress == null) {
                    type_of_order = out_of_app_order_type_without_address;
                  } else {
                    adrs = locationState.selectedOrderAddress;

                    if (adrs.isNotEmpty) {
                      type_of_order = out_of_app_order_type;
                    } else {
                      type_of_order = out_of_app_order_type_without_address;
                    }
                  }

                  payAtDelivery(
                      context,
                      ref,
                      type_of_order,
                      true
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.directions_bike,
                                color: KColors.primaryColor),
                            SizedBox(width: 5),
                            Text(
                                "${AppLocalizations.of(context).translate('pay_at_arrival')}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: KColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),

                      ]),
                ),
              ),
            ):
            Container()
          ],
        ),
      ),
    ),
    );
  }

}
