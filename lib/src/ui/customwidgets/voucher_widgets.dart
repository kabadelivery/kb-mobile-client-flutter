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
import '../../xrint.dart';
import 'MyVoucherMiniWidget.dart';
import 'billing_widget.dart';

Widget BuildCouponSpace(BuildContext context, WidgetRef ref) {
  return Consumer(builder: (context, ref, child) {
    final voucherState = ref.watch(voucherStateProvider);
    final voucherNotifier = ref.read(voucherStateProvider.notifier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
    final locationState = ref.watch(locationStateProvider);
    final locationNotifier = ref.read(locationStateProvider.notifier);
    final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    final productState = ref.watch(productListProvider);
    VoucherModel? voucherSelected = voucherState.selectedVoucher;

    xrint('VoucherModeler $voucherSelected');

      return Column(children: <Widget>[
        /* do you have a voucher you want to use ? */
        InkWell(
          onTap: () async {
            try {
              VoucherModel voucher =
                  await SelectVoucher(context, ref, false, null);
              await getBillingForVoucher(context, ref, voucher)
                  .then((value) async {
                if (value!.shipping_pricing == 0) {
                  showOutOfRangePopup(context);
                  outOfAppNotifier.setIsBillBuilt(false);
                  outOfAppNotifier.setShowLoading(false);
                } else {
                  orderBillingNotifier.setOrderBillConfiguration(value);
                  outOfAppNotifier.setIsBillBuilt(true);
                  outOfAppNotifier.setShowLoading(false);
                }
              });
            } catch (e) {
              xrint("ERROR getBillingForVoucher : $e");
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
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xffff9100),
                        KColors.primaryYellowColor,]),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                /* please choose a voucher. */
                child: Row(
                  mainAxisSize: MainAxisSize.min,

                    children: <Widget>[
                      IconButton(
                        icon: Icon(CupertinoIcons.tickets, color: KColors.white),
                        onPressed: () async {
                          VoucherModel? voucher = await SelectVoucher(
                              context, ref, false, null);
                          OrderBillConfiguration? orderBillConfiguration =
                              await getBillingForVoucher(
                                  context, ref, voucher!);

                          if (orderBillConfiguration!.shipping_pricing ==
                              0) {
                            showOutOfRangePopup(context);
                            outOfAppNotifier.setIsBillBuilt(false);
                            outOfAppNotifier.setShowLoading(false);
                          } else {
                            orderBillingNotifier.setOrderBillConfiguration(
                                orderBillConfiguration);
                            outOfAppNotifier.setIsBillBuilt(true);
                            outOfAppNotifier.setShowLoading(false);
                          }
                        },
                      ),
                      Text(
                          "${AppLocalizations.of(context)!.translate('add_coupon')}",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ])),
          ),
        ),
        _buildEligibleVoucher(context, ref, null)
      ]);
    });
}
Widget BuildVoucherSpace(BuildContext context, WidgetRef ref) {
  OrderBillConfiguration? orderBillConfiguration;
  final voucherState = ref.watch(voucherStateProvider);
  final voucherNotifier = ref.read(voucherStateProvider.notifier);
  final orderBillingState = ref.watch(orderBillingStateProvider);
  final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
  final locationState = ref.watch(locationStateProvider);
  final locationNotifier = ref.read(locationStateProvider.notifier);
  final outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
  final productState = ref.watch(productListProvider);
  VoucherModel? voucherSelected = voucherState.selectedVoucher;

//   _selectedVoucher
  return Column(
    children: [
      Stack(
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 10),
              child: MyVoucherMiniWidget(
                  voucher: voucherState.selectedVoucher,
                  isForOrderConfirmation: true)),
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
                        onPressed: () async {
                          List<Map<String, dynamic>> formData = [];

                          for (int i = 0; i < productState.length; i++) {
                            formData.add({
                              'name': productState[i]['name'],
                              'price': productState[i]['price'].toString(),
                              'quantity':
                              productState[i]['quantity'].toString(),
                              'image': ""
                            });
                          }
                          outOfAppNotifier.setIsBillBuilt(false);
                          outOfAppNotifier.setShowLoading(true);
                          OutOfAppOrderApiProvider api =
                          OutOfAppOrderApiProvider();
                          try {
                            await api
                                .computeBillingAction(
                                orderBillingState.customer!,
                                locationState.selectedOrderAddress!,
                                formData,
                                locationState.selectedShippingAddress!,
                                null,
                                false)
                                .then((value) {
                              voucherNotifier.state.selectedVoucher = null;
                              if (orderBillConfiguration!
                                  .shipping_pricing ==
                                  0) {
                                showOutOfRangePopup(context);
                                outOfAppNotifier.setIsBillBuilt(false);
                                outOfAppNotifier.setShowLoading(false);
                              } else {
                                orderBillingNotifier
                                    .setOrderBillConfiguration(
                                    orderBillConfiguration);
                                outOfAppNotifier.setIsBillBuilt(true);
                                outOfAppNotifier.setShowLoading(false);
                              }
                            });
                          } catch (e) {
                            Fluttertoast.showToast(
                                backgroundColor: Colors.black87,
                                textColor: Colors.white,
                                fontSize: 14,
                                toastLength: Toast.LENGTH_LONG,
                                msg: "🚨 " +
                                    AppLocalizations.of(context)!.translate(
                                        "impossible_to_load_bill") +
                                    " 🚨");
                            outOfAppNotifier.setIsBillBuilt(false);
                            outOfAppNotifier.setShowLoading(false);
                          }
                        }),
                  ),
                ),
              )),
        ],
      ),
      _buildEligibleVoucher(context, ref, orderBillConfiguration)
    ],
  );
}
Widget _buildEligibleVoucher(BuildContext context, WidgetRef ref,
    OrderBillConfiguration? orderBillConfiguration) {
  final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
  List<VoucherModel>? eligible_vouchers = orderBillConfiguration != null
      ? orderBillConfiguration.eligible_vouchers
      : [];
  if (orderBillConfiguration != null) {
    orderBillingNotifier.setOrderBillConfiguration(orderBillConfiguration);
    var outOfAppNotifier = ref.read(outOfAppScreenStateProvier.notifier);
    if (orderBillConfiguration.shipping_pricing == 0) {
      showOutOfRangePopup(context);
      outOfAppNotifier.setIsBillBuilt(false);
      outOfAppNotifier.setShowLoading(false);
    } else {
      orderBillingNotifier.setOrderBillConfiguration(orderBillConfiguration);
      outOfAppNotifier.setIsBillBuilt(true);
      outOfAppNotifier.setShowLoading(false);
    }
  }
  return Consumer(builder: (context, ref, child) {
    final voucherState = ref.watch(voucherStateProvider);
    final voucherNotifier = ref.read(voucherStateProvider.notifier);
    final orderBillingState = ref.watch(orderBillingStateProvider);
    final orderBillingNotifier = ref.read(orderBillingStateProvider.notifier);
    final locationState = ref.watch(locationStateProvider);
    final locationNotifier = ref.read(locationStateProvider.notifier);
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
              eligible_vouchers[index].use_count! -
                      eligible_vouchers[index].already_used_count! ==
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
                              "${eligible_vouchers[index].type == 1 ? "${AppLocalizations.of(context)!.translate('voucher_type_shop')}" : (eligible_vouchers[index].type == 2 ? "${AppLocalizations.of(context)!.translate('voucher_type_delivery')}" : "${AppLocalizations.of(context)!.translate('voucher_type_all')}")}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: KColors.new_black))
                        ]),
                        SizedBox(height: 5),
                        Text(eligible_vouchers[index].trade_name!,
                            style: TextStyle(color: Colors.grey, fontSize: 12))
                      ]),
                  GestureDetector(
                    onTap: () async {
                      VoucherModel? voucher = await SelectVoucher(
                          context, ref, true, eligible_vouchers[index]);
                      OrderBillConfiguration? orderBillConfiguration =
                          await getBillingForVoucher(context, ref, voucher!);

                      if (orderBillConfiguration!.shipping_pricing == 0) {
                        showOutOfRangePopup(context);
                        outOfAppNotifier.setIsBillBuilt(false);
                        outOfAppNotifier.setShowLoading(false);
                      } else {
                        orderBillingNotifier
                            .setOrderBillConfiguration(orderBillConfiguration);
                        outOfAppNotifier.setIsBillBuilt(true);
                        outOfAppNotifier.setShowLoading(false);
                      }
                    },
                    child: Container(
                      child: Text(
                          "${AppLocalizations.of(context)!.translate('voucher_use')}",
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

Widget VoucherWidgetSkin({required BuildContext context, required int amount}) {
/* restaurant voucher gradient */
  var restaurantVoucherBg = [Color(0xFFEAEB12), Color(0xFFF1AA00)];

/* delivery voucher gradient */
  var deliveryVoucherBg = [Color(0xFFCC1641), Color(0xFFFF7E9C)];

/* all voucher gradient */
  var bothVoucherBg = [Color(0xFFEEEEEE), Color(0xFFFFFFFF)];

  var textColorWhite = Color(0xFFFFFFFF);
  var textColorBlack = Color(0xFF000000);
  var textColorYellow = KColors.colorMainYellow;
  var textColorRed = KColors.colorCustom;

  return Shimmer(
      duration: Duration(seconds: 2),
      //Default value
      color: Colors.white,
      //Default value
      enabled: true,
      //Default value
      direction: ShimmerDirection.fromLTRB(),
      //Default Value
      child: ClipPath(
          clipper: VoucherListItemClipper(),
          child: Card(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10),
//              margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
              child: Container(
                  /* ACCORDING TO THE MODEL THE GRADIENT IS ALSO DIFFERENT */
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 0.0),
                      // 10% of the width, so there are ten blinds.
                      colors: deliveryVoucherBg,
                      tileMode: TileMode
                          .repeated, // repeats the gradient over the canvas
                    ),
                  ),
                  child: Column(children: [
                    Stack(children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 10),
                              Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
/* JUST SHOW IT */
                                    Row(
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.code,
                                            color: textColorWhite, size: 15),
                                        SizedBox(width: 10),
                                        Text(
                                            "${AppLocalizations.of(context)!.translate('voucher_new_user')}"
                                                .toUpperCase(),
                                            style: TextStyle(
                                                color: textColorWhite,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
/* superposing two stuffs */
Text("-${amount}F".toUpperCase(),style: TextStyle(color: Colors.amberAccent, fontSize: 19, fontWeight: FontWeight.bold)),
                                  ]),
                              SizedBox(height: 10),
                            ],
                          ))
                    ]),
                    SizedBox(height: 20),
                    Text("${AppLocalizations.of(context)!.translate('new_user_voucher_info')}",
                        style: TextStyle(
                            color: textColorWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.normal)),
                    SizedBox(height: 20),
                  ])))));
}


Widget BuildSubSpace(BuildContext context, WidgetRef ref){
  return Shimmer(
    duration: Duration(seconds: 2),
    //Default value
    color: Colors.white,
    //Default value
    enabled: true,
    //Default value
    direction: ShimmerDirection.fromLTRB(),
    child: GestureDetector(
      onTap: () async {

      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xff730920),
                KColors.primaryColor,]),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.code, color: KColors.white),
              onPressed: () async {},
            ),
            Text(
                "Ajouter Code Abon.",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    ),
  );
}

class SubscriptionCard extends StatelessWidget {
  final int priceSaved;
  const SubscriptionCard({super.key,required this.priceSaved});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors:
          [
            Color(0xFFFFDADF),
            Color(0xFFFFECD5)
          ], // dégradé doux
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KColors.primaryColor, width: 0.5)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: const [
              Icon(Icons.emoji_objects, color: KColors.primaryColor),
              SizedBox(width: 8),
              Text(
                "Vous économisez sur votre livraison !",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: KColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Texte principal
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Cette livraison vous coutêra ",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                TextSpan(
                  text: "0 Franc",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text:
                  " grâce à votre formule d'abonnement Kaba.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Économie
           Row(
             children: [
               Icon(FontAwesomeIcons.boltLightning, color: Colors.green,size: 12,),
               Text(
                "Économie : ${priceSaved} FCFA",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                         ),
             ],
           ),
        ],
      ),
    );
  }
}