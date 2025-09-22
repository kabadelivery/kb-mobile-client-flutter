import 'dart:io';

import 'package:KABA/src/models/DeliveryAddressModel.dart';
import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:KABA/src/utils/_static_data/LottieAssets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../StateContainer.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/VoucherModel.dart';
import '../../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../../utils/functions/OutOfAppOrder/dialogToFetchShippingPrice.dart';
import '../../../utils/functions/OutOfAppOrder/launchOrder.dart';
import '../../../utils/functions/OutOfAppOrder/resetProviders.dart';
import '../../../utils/functions/Utils.dart';
import '../../../xrint.dart';
import '../../customwidgets/MyLoadingProgressWidget.dart';
import '../../customwidgets/additionnal_info_widget.dart';
import '../../customwidgets/address_additionnal_info_widget.dart';
import '../../customwidgets/billing_widget.dart';
import '../../customwidgets/choose_locations_widget.dart';
import '../../customwidgets/explanation_widgets.dart';
import '../../customwidgets/out_of_app_product_form_widget.dart';
import '../../customwidgets/out_of_app_product_widget.dart';
import '../../customwidgets/voucher_widgets.dart';

class OutOfAppOrderPage extends ConsumerStatefulWidget {
  static var routeName = "/OutOfAppOrderPage";

  @override
  ConsumerState<OutOfAppOrderPage> createState() => _OutOfAppOrderPageState();
}

class _OutOfAppOrderPageState extends ConsumerState<OutOfAppOrderPage> {
  int shipping_address_type=1;
  int order_address_type=2;
  int simple_additionnal_info_type =1;
  int address_additionnal_info_type=2;
  int out_of_app_order_type=3;
  int out_of_app_order_type_without_address=4;
  bool reset = true;
  GlobalKey poweredByKey = GlobalKey();
  void showOutOfAppProductForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: OutOfAppProductForm(),
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reset) {
        resetProviders(ref);
        reset = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final products = ref.watch(productListProvider);
    final outOfAppScreenState = ref.watch(outOfAppScreenStateProvier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final locationState = ref.watch(locationStateProvider);
    final locationNotifier = ref.read(locationStateProvider.notifier);
    final voucherState = ref.watch(voucherStateProvider);
    final additionnalInfoState = ref.watch(additionnalInfoProvider); 

   if(locationState.selectedOrderAddress==null){
     locationState.selectedOrderAddress = [];

    }
    //    outOfAppScreenState.order_type=3;
    // outOfAppScreenState.isBillBuilt=false;
    // outOfAppScreenState.showLoading=false;
    xrint("shipping_address ${locationState.selectedShippingAddress}");
    xrint("shipping_address order_address ${locationState.selectedOrderAddress}");
    if(locationState.selectedOrderAddress!.isNotEmpty && locationState.selectedShippingAddress!=null){
      if(locationState.selectedOrderAddress![0].id==(locationState.selectedShippingAddress!.id)){

        Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context)!.translate("same_address_cant_be_picked")+" 🚨");
        outOfAppScreenState.isBillBuilt=false;
        outOfAppScreenState.showLoading=false;

      }
    }
    return  Scaffold(
        appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        backgroundColor: KColors.primaryColor,
        centerTitle: true,
        title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
        Utils.capitalize(
        "${AppLocalizations.of(context)!.translate('out_of_app_order')}"),
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
            outOfAppScreenState.is_explanation_space_visible==true?
            BuildExplanationSpace(
              context,
              ref,
              AppLocalizations.of(context)!.translate('out_of_app_explanation'),
              "https://lottie.host/0b8428d8-5220-452a-929c-da6701e5c25b/3xLtR3XYdy.json"
              ):Container(),
              SizedBox(height: 10,),
            IconButton(
              icon: Icon(Icons.add_circle, color: KColors.primaryColor, size: 40),
              onPressed: () {
                showOutOfAppProductForm(context);
              },
            ),
            Container(
              padding:EdgeInsets.all(15),
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 5)),
                  ]
                ),
                child:
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: KColors.primaryColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Icon(FontAwesomeIcons.box,color: Colors.white,size: 20,),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Ma commande",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,)),
                        Text('${products.length} ${products.length>1?"produits sélectionnés":"produit sélectionné"}')
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10,),
                products.isNotEmpty
                    ? Column(
                  children: products.map((product) {
                    int index = products.indexOf(product);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      child: OutOfAppProductItem(
                        context,
                        ref,
                        index,
                        product['image'] ?? File(''),
                        product['name'],
                        product['price'],
                        product['quantity'],
                      ),
                    );
                  }).toList(),
                )
                    : const Center(
                  child: Text('Aucun produit'),
                ),

              ],
            )
            ),
            products.isNotEmpty ?
            Column(
              children: [
            SizedBox(height: 20,),
            outOfAppScreenState.showLoading==false?
              Column(
                children: [
                  PurchaseAddress(context,ref,order_address_type,poweredByKey,order_address_type,0),
                 SizedBox(height: 20,),
                  ShippingAddress(context,ref,shipping_address_type,poweredByKey,shipping_address_type,0),
                  SizedBox(height: 20,),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: Offset(0, 5)),
                        ]

                    ),
                    width: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: KColors.primaryColor,
                                borderRadius: BorderRadius.circular(10),

                              ),
                              child: const Icon(
                                Icons.receipt_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Text("Infos supplémentaires",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text("Instructions particulières",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color:Colors.black54),),
                        SizedBox(height: 10,),
                        AdditionnalInfo(context,ref,simple_additionnal_info_type,additionnalInfoState.additionnal_info),
                        SizedBox(height: 10,),
                        Text("Image du magasin/ordonnance (optionnel)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color:Colors.black54),),
                        SizedBox(height: 10,),
                        AdditionnalInfoImage(context,ref),
                        SizedBox(height: 10,),
                        PhoneNumberForm(context,outOfAppScreenState.phone_number,ref),
                        SizedBox(height: 10,),
                      ],
                    ),
                  ),
          
                ],
              )  :Container()
              ],
            ):Container(),
            SizedBox(height: 20,),
            Container(
              width: 350,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BuildSubSpace(context,ref),
                  BuildCouponSpace(context,ref),
                ],
              ),
            ),
            orderBillingState.orderBillConfiguration!=null?
            Column(
            children: [
              SizedBox(height: 20),
              SubscriptionCard(priceSaved: orderBillingState.orderBillConfiguration!.shipping_pricing!,)
            ],
          ):Container(),
          voucherState.selectedVoucher!=null?    Column(
            children: [
              SizedBox(height: 20,),
              Container(
                    width: 370,
                    child: BuildVoucherSpace(context,ref)),
            ],
          ):Container(),
            SizedBox(height: 20,),
            outOfAppScreenState.isBillBuilt==true &&
                outOfAppScreenState.showLoading==false?
            Container(
                width: 350,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),

                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 5)),
                    ]
                ),

                child: ShowBilling(context,orderBillingState.orderBillConfiguration!)):
            outOfAppScreenState.showLoading==true?
            MyLoadingProgressWidget()
                :Container()
            ,
            SizedBox(height: 20,),
            Container(
              width: 350,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xff730920),
                        KColors.primaryColor,]),
                  borderRadius: BorderRadius.all(Radius.circular(10))),

              child: InkWell(
                onTap: () async {
                  int type_of_order = 4; // Default
                  bool? result = false;
                  List<DeliveryAddressModel>? adrs = [];

                  if (locationState.selectedOrderAddress!.isEmpty) {
                    type_of_order = out_of_app_order_type_without_address;
                    result = await showShippingPriceRangeInfo(context,ref, type_of_order);
                  } else {
                    adrs = locationState.selectedOrderAddress;
                    if (adrs!.isNotEmpty) {
                      type_of_order = out_of_app_order_type;
                    } else {
                      type_of_order = out_of_app_order_type_without_address;
                    }
                     result = true;
                  }
                  if(result==true){
                    payAtDelivery(
                        context,
                        ref,
                        type_of_order,
                        true
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                                "${AppLocalizations.of(context)!.translate('pay_at_arrival')}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color:Colors.white,
                                  fontWeight: FontWeight.w500,
                                )),
                          ],
                        ),

                      ]),
                ),
              ),
            ),
            SizedBox(height: 40,),
          ],
        ),
      ),
    ),
    );
  }

}
