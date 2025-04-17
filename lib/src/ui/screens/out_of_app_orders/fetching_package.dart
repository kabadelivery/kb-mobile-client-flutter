import 'dart:io';

import 'package:KABA/src/ui/screens/out_of_app_orders/shipping_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../StateContainer.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/DeliveryAddressModel.dart';
import '../../../models/OrderBillConfiguration.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/additionnal_info_state.dart';
import '../../../state_management/out_of_app_order/district_state.dart';
import '../../../state_management/out_of_app_order/location_state.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import '../../../state_management/out_of_app_order/products_state.dart';
import '../../../state_management/out_of_app_order/reset_states.dart';
import '../../../state_management/out_of_app_order/voucher_state.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../../utils/functions/OutOfAppOrder/launchOrder.dart';
import '../../../utils/functions/OutOfAppOrder/resetProviders.dart';
import '../../../utils/functions/Utils.dart';
import '../../customwidgets/ChooseDistrict.dart';
import '../../customwidgets/MyLoadingProgressWidget.dart';
import '../../customwidgets/additionnal_info_widget.dart';
import '../../customwidgets/address_additionnal_info_widget.dart';
import '../../customwidgets/billing_widget.dart';
import '../../customwidgets/choose_locations_widget.dart';
import '../../customwidgets/explanation_widgets.dart';
import '../../customwidgets/out_of_app_product_form_widget.dart';
import '../../customwidgets/out_of_app_product_widget.dart';
import '../../customwidgets/voucher_widgets.dart';

class FecthingPackageOrderPage extends ConsumerStatefulWidget {
  static var routeName = "/FecthingPackageOrderPage";
  final String additional_info;
  final File additionnal_info_image;
  final List<Map<String,dynamic>> districts;
  FecthingPackageOrderPage({this.additional_info,this.additionnal_info_image,this.districts});

  @override
  ConsumerState<FecthingPackageOrderPage> createState() => _FecthingPackageOrderPageState();
}

class _FecthingPackageOrderPageState extends  ConsumerState<FecthingPackageOrderPage> {
  int shipping_address_type=1;
  int order_address_type=2;
  int simple_additionnal_info_type =1;
  int address_additionnal_info_type=2;
  int out_of_app_order_type=3;
  int out_of_app_order_type_without_address=4;
  int shipping_package_type = 5;
  int fetching_package_type = 6;
  bool reset = true;
  GlobalKey poweredByKey = GlobalKey();
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
    final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    final productsNotifier = ref.read(productListProvider.notifier);
    final districtState = ref.watch(districtProvider);
    if(locationState.selectedOrderAddress.isEmpty){
      locationState.is_order_address_picked=false;
    }else{
      locationState.is_order_address_picked=true;
    }
    if(locationState.selectedOrderAddress==null){
      locationState.selectedOrderAddress=[];
    }
    districtState.districts = widget.districts;
    outOfAppScreenState.order_type=6;
    if(locationState.is_order_address_picked && locationState.is_shipping_address_picked){
      if(locationState.selectedOrderAddress[0].id==(locationState.selectedShippingAddress.id)){

        Fluttertoast.showToast(
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
            toastLength: Toast.LENGTH_LONG ,
            msg: "🚨 "+AppLocalizations.of(context).translate("same_address_cant_be_picked")+" 🚨");
        outOfAppScreenState.isBillBuilt=false;
        outOfAppScreenState.showLoading=false;

      }
    }
    return  Scaffold(
      appBar: AppBar(
        toolbarHeight: StateContainer.ANDROID_APP_SIZE,
        brightness: Brightness.light,
        backgroundColor: KColors.primaryColor,
        centerTitle: true,

      leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context).translate('package_order')}"),
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
        child:Column(
          children: [
                   Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: 40,

                width: MediaQuery.of(context).size.width*.95,
                decoration: BoxDecoration(
                    color: Color(0x6EC5C5C5),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () { 
                        resetAll(ref);
                        productsNotifier.setProducts([]);
                        Navigator.of(context).pushReplacement(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ShippingPackageOrderPage(
                            additional_info: additionnalInfoState.additionnal_info,
                            additionnal_info_image: additionnalInfoState.image,
                            districts: widget.districts,
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var begin = Offset(-1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end);
                            var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                            return SlideTransition(
                              position: tween.animate(curvedAnimation),
                              child: child
                            );
                          }
                        ));
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        height: 40,
                        width: (MediaQuery.of(context).size.width*.95)/2,
                        decoration: BoxDecoration(
                            color: outOfAppScreenState.order_type!=5?
                            Colors.transparent:
                            KColors.primaryColor,
                            borderRadius: BorderRadius.only(
                                topLeft:Radius.circular(10),
                                bottomLeft:Radius.circular(10)
                            )
                        ),
                        child: Text(
                            "${AppLocalizations.of(context).translate('shipping_package')}",
                            style: TextStyle(
                                fontSize: 15,
                                color:outOfAppScreenState.order_type==5? Colors.white :KColors.new_black)),
                      ),
                    ),
                    GestureDetector(
                      onTap: null,
                      child:  AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        alignment: Alignment.center,
                        height: 40,
                        width: (MediaQuery.of(context).size.width*.95)/2,
                        decoration: BoxDecoration(
                            color: outOfAppScreenState.order_type==6?
                            KColors.primaryColor:
                            Colors.transparent,
                            borderRadius: BorderRadius.only(
                                topRight:Radius.circular(10),
                                bottomRight:Radius.circular(10)
                            )
                        ),
                        child:  Text(
                            "${AppLocalizations.of(context).translate('fetch_package')}",
                            style: TextStyle(
                                fontSize: 15,
                                color:outOfAppScreenState.order_type==6? Colors.white :Colors.grey)),
                      ),
                    )
                  ],
                ),
              ),
            ),
        
              SizedBox(
                height: 10,
              ),

            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
            outOfAppScreenState.is_explanation_space_visible==true?
            BuildExplanationSpace(
              context,
              ref,
              AppLocalizations.of(context).translate('fetch_package_explanation'),
              "https://lottie.host/3d2464c8-af6a-4d67-a85e-4deaf161f191/HOYpXSXAdg.json"
              ):Container(),  
              SizedBox(height: 10,),
                    Text(AppLocalizations.of(context).translate("package_details"),style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600,color: KColors.new_black),),
                    SizedBox(height: 10,),
                    AdditionnalInfo(context,ref,simple_additionnal_info_type,additionnalInfoState.additionnal_info),
                    AdditionnalInfoImage(context,ref),
                    SizedBox(height: 10),
                    outOfAppScreenState.isBillBuilt==true &&
                        outOfAppScreenState.showLoading==false?
                    ShowBilling(context,orderBillingState.orderBillConfiguration):
                    outOfAppScreenState.showLoading==true?
                    MyLoadingProgressWidget()
                        :Container(),
                    ((outOfAppScreenState.order_type == fetching_package_type && additionnalInfoState.additionnal_info.isNotEmpty))
                    ? Column(
                      children: [
                                  Column(
                          children: [
                          SizedBox(height: 10,),
                           locationState.selectedOrderAddress.isEmpty?
                            Column(
                              children: [
                                ChooseShippingAddress(context,ref,order_address_type,poweredByKey,order_address_type,fetching_package_type),
                                SizedBox(height: 20,),
                                additionnalInfoState.can_add_address_info==null?
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        "${AppLocalizations.of(context).translate('add_district_info')}",
                                        style: TextStyle(

                                            fontSize: 16,
                                            color: Colors.grey.shade700)),
                                    SizedBox(height: 10,),
                                    CanAddAdditionnInfo(context,ref),
                                  ],
                                ):
                                additionnalInfoState.can_add_address_info==true && outOfAppScreenState.isBillBuilt==false?
                                Column(
                                  children: [
                                    DistrictSelectionWidget(),
                                    SizedBox(height: 20,),
                                  ],
                                ):Container(),
                              ],
                            ):Container(),
                           additionnalInfoState.can_add_address_info==true?
                           AdditionnalInfo(context,ref,address_additionnal_info_type,additionnalInfoState.additionnal_address_info)
                           :Container(),
                           SizedBox(height: 10,),
                           locationState.selectedOrderAddress.isNotEmpty ?
                            Column(
                              children: [
                                Text(
                                    "${AppLocalizations.of(context).translate('fecthing_package_address')}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: KColors.new_black)),
                                BuildOrderAddress(context,ref,locationState.selectedOrderAddress[0]),
                              ],
                            ):Container(),
                          ],
                        ),
                        SizedBox(height: 10,),
                        locationState.is_shipping_address_picked==true  ?
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
                        ChooseShippingAddress(context,ref,shipping_address_type,poweredByKey,shipping_address_type,fetching_package_type),
                       ],
                    ) : Container(),
                      SizedBox(height: 10,),
                    PhoneNumberForm(context,outOfAppScreenState.phone_number,ref),
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
                          if(outOfAppScreenState.phone_number.isEmpty || outOfAppScreenState.phone_number.length<8){
                                Fluttertoast.showToast(
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 14,
                                    toastLength: Toast.LENGTH_LONG ,
                                    msg: "🚨 "+AppLocalizations.of(context).translate("enter_correct_phone_number")+" 🚨");
                          }
                          else{
                                        int type_of_order = 6;
                                        ref
                                            .read(productListProvider.notifier)
                                            .clearProducts();
                                        File image;
                                        if (additionnalInfoState.image !=
                                            null) {
                                          image = File(
                                              additionnalInfoState.image.path);
                                        } else {
                                          image = null;
                                        }
                                        ref
                                            .read(productListProvider.notifier)
                                            .addProduct({
                                          "name": "Récupération de colis",
                                          "price": outOfAppScreenState
                                              .package_amount,
                                          "quantity": 1,
                                          "image": image,
                                        });

                                        payAtDelivery(
                                            context, ref, type_of_order, true);
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
      ]),
    )
    );
  }

}

