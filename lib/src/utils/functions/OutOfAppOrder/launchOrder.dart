import 'dart:convert';

import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/state_management/out_of_app_order/additionnal_info_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:KABA/src/utils/functions/OutOfAppOrder/resetProviders.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:vibration/vibration.dart';

import '../../../StateContainer.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/CustomerModel.dart';
import '../../../models/DeliveryAddressModel.dart';
import '../../../models/VoucherModel.dart';
import '../../../resources/out_of_app_order_api.dart';
import '../../../state_management/out_of_app_order/order_billing_state.dart';
import '../../../ui/screens/auth/pwd/RetrievePasswordPage.dart';
import '../../../ui/screens/home/HomePage.dart';
import '../../../xrint.dart';
import '../../_static_data/ImageAssets.dart';
import '../../_static_data/KTheme.dart';
import '../../_static_data/MusicData.dart';
import '../../_static_data/Vectors.dart';
import '../CustomerUtils.dart';
import '../Utils.dart';
import 'imagePicker.dart';

Future<void> launchOrderFunc(
    CustomerModel customer,
    List<Map<String, dynamic>> foods,
    List<DeliveryAddressModel> order_adress,
    DeliveryAddressModel selectedAddress,
    String mCode,
    String infos,
    VoucherModel? voucher,
    bool useKabaPoint,
    int order_type,
    BuildContext context,
    WidgetRef ref,
    String phone_number,
    String infos_image) async {
  OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
  try {
    int error = await api.launchOrder(
        true,
        customer,
        order_adress,
        foods,
        selectedAddress,
        mCode,
        infos,
        voucher??VoucherModel(),
        useKabaPoint,
        order_type,
        phone_number,
        infos_image);
    launchOrderResponse(error, context, ref);
  } catch (_) {
    /* login failure */
    xrint("error ${_}");
    if (_ == -2) {
      //    _orderConfirmationView.systemError();
    } else {
      //    _orderConfirmationView.networkError();
    }
    //  _orderConfirmationView.launchOrderResponse(-1);
  }
//  isWorking = false;
}

void mToast(String message, BuildContext context) {
  Toast.show(message,duration:5);
}

void sorryDemoAccountAlert(BuildContext context, WidgetRef ref) {
  // show alert for demo-account saying how you can't order

  _showDialog(
      asset_png: ImageAssets.demo_icon, // untrustful
      message:
          "${AppLocalizations.of(context)!.translate('demo_account_alert')}",
      isYesOrNo: false,
      context: context,
      ref: ref);
}

void payAtDelivery(
  BuildContext context,
  WidgetRef ref,
  int order_type,
  bool isDialogShown,
) async {
  const String DEMO_ACCOUNT_USERNAME = "90000000";

  OrderBillConfiguration? orderBillConfiguration =
      ref.watch(orderBillingStateProvider).orderBillConfiguration;
  CustomerModel? customer = ref.watch(orderBillingStateProvider).customer;
  String phone_number = ref.watch(outOfAppScreenStateProvier).phone_number;
  var foods = ref.watch(productListProvider);
  List<DeliveryAddressModel>? order_address =
      ref.watch(locationStateProvider).selectedOrderAddress;
  var _selectedAddress =
      ref.watch(locationStateProvider).selectedShippingAddress;
  var addInfo = "\nInfos supplémentaire : " +
      "\n\n" +
      ref.watch(additionnalInfoProvider).additionnal_info +
      "\n\n\n" +
      "Infos sur l'addresse de commande : \n\n" +
      ref.watch(additionnalInfoProvider).additionnal_address_info;
  var _selectedVoucher = ref.watch(voucherStateProvider).selectedVoucher;
  var _usePoint = ref.watch(voucherStateProvider).usePoint;

  if (orderBillConfiguration?.trustful != 1) {
    if (Utils.isEmailValid(customer!.username!)) {
      // email account
      _showDialog(
          iccon: VectorsData.questions, // untrustful
          message:
              "${AppLocalizations.of(context)!.translate('sorry_email_account_no_pay_delivery')}",
          isYesOrNo: false,
          context: context);
    } else {
      _showDialog(
          iccon: VectorsData.questions, // untrustful
          message:
              "${AppLocalizations.of(context)!.translate('sorry_ongoing_order')}",
          isYesOrNo: false,
          context: context);
    }
    return;
  }

  if (!isDialogShown) {
    _showDialog(
        iccon: VectorsData.questions,
        message:
            "${AppLocalizations.of(context)!.translate('prevent_pay_at_delivery')}",
        isYesOrNo: true,
        context: context,
        actionIfYes: () => payAtDelivery(
              context,
              ref,
              order_type,
              true,
            ));
    return;
  }

  // 1. get password
  var results = await Navigator.of(context)
      .push(new MaterialPageRoute<dynamic>(builder: (BuildContext context) {
    return RetrievePasswordPage(type: 3);
  }));
  // retrieve password then do it,
  if (results != null &&
      results.containsKey('code') &&
      results.containsKey('type')) {
    if (results == null ||
        results['code'] == null ||
        !Utils.isCode(results['code'])) {
      mToast(
          "${AppLocalizations.of(context)!.translate('wrong_code')}", context);
    } else {
      String _mCode = results['code'];

      if ("${customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) == 0) {
        sorryDemoAccountAlert(context, ref);
      } else {
        ref
            .read(outOfAppScreenStateProvier.notifier)
            .setIsPayAtDeliveryLoading(true);
        if (Utils.isCode(_mCode)) {
          try {
            OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
            final uploadedOrders =
                await api.uploadMultipleImages(foods, customer!);
            if (uploadedOrders.isNotEmpty) {
              foods = [];
              for (var order in uploadedOrders) {
                foods.add({
                  "name": order["name"],
                  "price": order["price"],
                  "quantity": order["quantity"],
                  "image": order["image"],
                });
              }
            }
            final addInfoImage = [
              {
                "name": "additionnal_info",
                "price": 0,
                "quantity": 1,
                "image": ref.watch(additionnalInfoProvider).image,
              }
            ];
            final uploadAdditionnalInfoImage =
                await api.uploadMultipleImages(addInfoImage, customer);
            await launchOrderFunc(
                customer,
                foods, //foods,
                order_address!,
                _selectedAddress!,
                _mCode,
                addInfo,
                _selectedVoucher,
                _usePoint!,
                order_type,
                context,
                ref,
                phone_number,
                uploadAdditionnalInfoImage[0]["image"]);

            await deleteCachedPickedImages();
          } catch (e) {
             xrint("LAUNCHING ORDER ERROR $e");
          }
        } else {
          mToast("${AppLocalizations.of(context)!.translate('wrong_code')}",
              context);
        }
      }
    }
  }
}

void _showDialog({
  String? iccon,
  Icon? icon,
  String? message,
  bool okBackToHome = false,
  bool isYesOrNo = false,
  Function? actionIfYes,
  String? asset_png,
  required BuildContext context,
  WidgetRef? ref,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or image
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      KColors.primaryColor,
                      KColors.primaryColor.withOpacity(.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.delivery_dining, // tu peux remplacer par Image.asset
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Message
              Text(
                message ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              isYesOrNo
                  ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "${AppLocalizations.of(context)!.translate('refuse')}",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: KColors.primaryColor, width: 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: KColors.primaryColor.withOpacity(0.1),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        actionIfYes?.call();
                      },
                      child: Text(
                        "${AppLocalizations.of(context)!.translate('accept')}",
                        style: TextStyle(color: KColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    "${AppLocalizations.of(context)!.translate('ok')}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    if (!okBackToHome) {
                      try {
                        resetProviders(ref!);
                        xrint("Resetting providers successfully");
                      } catch (e) {
                        xrint("Error resetting providers: $e");
                      }
                      Navigator.of(context).pop();
                    } else {
                      StateContainer.of(context).updateTabPosition(tabPosition: 2);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(name: HomePage.routeName),
                          builder: (_) => HomePage(is_out_of_app_order: true),
                        ),
                            (r) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
void launchOrderResponse(int errorCode, BuildContext context, WidgetRef ref) {
  ref
      .read(outOfAppScreenStateProvier.notifier)
      .setIsPayAtDeliveryLoading(false);
  xrint("ERROR CODE $errorCode");
  if (errorCode == 0) {
    CustomerUtils.unlockBestSellerVersion();
    _showOrderSuccessDialog(context, ref);
  } else {
    String message = "";
    switch (errorCode) {
      case 300:
        message =
            "${AppLocalizations.of(context)!.translate('300_wrong_password')}";
        break;
      case 301: // restaurant doesnt exist
        message =
            "${AppLocalizations.of(context)!.translate('301_server_issue')}";
        break;
      case 302:
        message =
            "${AppLocalizations.of(context)!.translate('302_unable_pay_at_arrival')}";
        break;
      case 303:
        message =
            "${AppLocalizations.of(context)!.translate('303_unable_online_payment')}";
        break;
      case 304:
        message =
            "${AppLocalizations.of(context)!.translate('304_address_error')}";
        break;
      case 305:
        message =
            "${AppLocalizations.of(context)!.translate('305_308_balance_insufficient')}";
        break;
      case 306:
        message =
            "${AppLocalizations.of(context)!.translate('306_account_error')}";
        break;
      case 307:
        message =
            "${AppLocalizations.of(context)!.translate('307_unable_preorder')}";
        break;
      case 308:
        message =
            "${AppLocalizations.of(context)!.translate('305_308_balance_insufficient')}";
        break;
      default:
        message =
            "${AppLocalizations.of(context)!.translate('309_system_error')}";
    }
    _showDialog(
        icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.red),
        message: message,
        isYesOrNo: false,
        context: context,
        ref: ref);
  }
}

void _showOrderSuccessDialog(BuildContext context, WidgetRef ref) {
  /* save the order, in spending ... */
  _playMusicForSuccess();
  _showDialog(
      okBackToHome: true,
      iccon: VectorsData.delivery_nam,
      message:
          "${AppLocalizations.of(context)!.translate('order_congratz_praise')}",
      isYesOrNo: false,
      context: context,
      ref: ref);
}

Future<void> _playMusicForSuccess() async {
  // play music
  final player = AudioPlayer();
  player.play(UrlSource(MusicData.command_success_hold_on));
  if (await Vibration.hasVibrator() != null) {
    Vibration.vibrate(duration: 500);
  }
}
