import 'package:KABA/src/models/OrderBillConfiguration.dart';
import 'package:KABA/src/state_management/out_of_app_order/additionnal_info_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/location_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/out_of_app_order_screen_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/products_state.dart';
import 'package:KABA/src/state_management/out_of_app_order/voucher_state.dart';
import 'package:audioplayer/audioplayer.dart';
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

Future<void> launchOrderFunc(
    CustomerModel customer,
    List<Map<String,dynamic>>foods,
    List<DeliveryAddressModel> order_adress,
    DeliveryAddressModel selectedAddress,
    String mCode,
    String infos,
    VoucherModel voucher,
    bool useKabaPoint,
    int order_type,
    BuildContext context,
    WidgetRef ref
    ) async {
  OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
  try {

    int error = await api.launchOrder(true, customer, order_adress,foods, selectedAddress, mCode, infos, voucher, useKabaPoint,order_type);
    launchOrderResponse(error,context,ref);
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
void mToast(String message,BuildContext context) {
  Toast.show(message, context, duration: Toast.LENGTH_LONG);
}
void sorryDemoAccountAlert(BuildContext context) {
  // show alert for demo-account saying how you can't order

  _showDialog(
    asset_png: ImageAssets.demo_icon, // untrustful
    message:
    "${AppLocalizations.of(context).translate('demo_account_alert')}",
    isYesOrNo: false,
    context: context
  );
}
void payAtDelivery(
    BuildContext context,
    WidgetRef ref,
    int order_type,
    bool isDialogShown,
    ) async {
  const String DEMO_ACCOUNT_USERNAME = "90000000";

  OrderBillConfiguration orderBillConfiguration = ref.watch(orderBillingStateProvider).orderBillConfiguration;
  CustomerModel customer = ref.watch(orderBillingStateProvider).customer;
  var foods = ref.watch(productListProvider);
  List<DeliveryAddressModel> order_address = ref.watch(locationStateProvider).selectedOrderAddress;
  var _selectedAddress = ref.watch(locationStateProvider).selectedShippingAddress;
  var addInfo = "\nInfos supplémentaire : "+"\n\n"+
      ref.watch(additionnalInfoProvider).additionnal_info+"\n\n\n"+
      "Infos sur l'addresse de commande : \n\n"+ref.watch(additionnalInfoProvider).additionnal_address_info;
  var _selectedVoucher = ref.watch(voucherStateProvider).selectedVoucher;
  var _usePoint = ref.watch(voucherStateProvider).usePoint;
  if (orderBillConfiguration?.trustful != 1) {
    if (Utils.isEmailValid(customer?.username)) {
      // email account
      _showDialog(
        iccon: VectorsData.questions, // untrustful
        message:
        "${AppLocalizations.of(context).translate('sorry_email_account_no_pay_delivery')}",
        isYesOrNo: false,
        context: context
      );
    } else {
      _showDialog(
        iccon: VectorsData.questions, // untrustful
        message:
        "${AppLocalizations.of(context).translate('sorry_ongoing_order')}",
        isYesOrNo: false,
        context: context
      );
    }
    return;
  }

  if (!isDialogShown) {
    _showDialog(
        iccon: VectorsData.questions,
        message:
        "${AppLocalizations.of(context).translate('prevent_pay_at_delivery')}",
        isYesOrNo: true,
        context: context,
        actionIfYes: () => payAtDelivery(context,ref,order_type,true,));
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
      mToast("${AppLocalizations.of(context).translate('wrong_code')}",context);
    } else {
      String _mCode = results['code'];

      if ("${customer?.username}".compareTo(DEMO_ACCOUNT_USERNAME) ==
          0) {
        sorryDemoAccountAlert(context);
      } else {
        ref.read(outOfAppScreenStateProvier.notifier).setIsPayAtDeliveryLoading(true);
        if (Utils.isCode(_mCode)) {

          try{
            OutOfAppOrderApiProvider api = OutOfAppOrderApiProvider();
            print("Upload image : $foods");
        //    var orderDetails = await api.uploadMultipleImages(foods,customer);
        //    print("orderDetails $orderDetails");
               await launchOrderFunc(
                            customer,
                           foods,// orderDetails as List<Map<String,dynamic>>,
                            order_address,
                            _selectedAddress,
                            _mCode,
                            addInfo,
                            _selectedVoucher,
                            _usePoint,
                            order_type,
                            context,
                            ref
                        );
          }catch(e){
            return;
          }

        } else {
          mToast("${AppLocalizations.of(context).translate('wrong_code')}",context);
        }
      }
    }
  }
}
void _showDialog(
    {String iccon,
      Icon icon,
      var message,
      bool okBackToHome = false,
      bool isYesOrNo = false,
      Function actionIfYes,
      String asset_png = null,
      BuildContext context
    }) {

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            SizedBox(
                height: 80,
                width: 80,
                child: asset_png != null
                    ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: new AssetImage(asset_png),
                        )))
                    : (icon == null
                    ? SvgPicture.asset(
                  iccon,
                )
                    : icon)),
            SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: KColors.new_black, fontSize: 13))
          ]),
          actions: isYesOrNo
              ? <Widget>[
            OutlinedButton(
              style: ButtonStyle(
                  side: MaterialStateProperty.all(
                      BorderSide(color: Colors.grey, width: 1))),
              child: new Text(
                  "${AppLocalizations.of(context).translate('refuse')}",
                  style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton(
              style: ButtonStyle(
                  side: MaterialStateProperty.all(BorderSide(
                      color: KColors.primaryColor, width: 1))),
              child: new Text(
                  "${AppLocalizations.of(context).translate('accept')}",
                  style: TextStyle(color: KColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
                actionIfYes();
              },
            ),
          ]
              : <Widget>[
            //
            OutlinedButton(
              child: new Text(
                  "${AppLocalizations.of(context).translate('ok')}",
                  style: TextStyle(color: KColors.primaryColor)),
              onPressed: () {
                if (!okBackToHome) {
                  Navigator.of(context).pop();
                } else {
                  StateContainer.of(context)
                      .updateTabPosition(tabPosition: 2);
                  Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          settings:
                          RouteSettings(name: HomePage.routeName),
                          builder: (BuildContext context) =>
                              HomePage()),
                          (r) => false);
                }
              },
            ),
          ]);
    },
  );
}
void launchOrderResponse(int errorCode,BuildContext context, WidgetRef ref) {

 ref.read(outOfAppScreenStateProvier.notifier).setIsPayAtDeliveryLoading(false);
 print("ERROR CODE $errorCode");
  if (errorCode == 0) {
    CustomerUtils.unlockBestSellerVersion();
    _showOrderSuccessDialog(context);
  } else {
    String message = "";
    switch (errorCode) {
      case 300:
        message =
        "${AppLocalizations.of(context).translate('300_wrong_password')}";
        break;
      case 301: // restaurant doesnt exist
        message =
        "${AppLocalizations.of(context).translate('301_server_issue')}";
        break;
      case 302:
        message =
        "${AppLocalizations.of(context).translate('302_unable_pay_at_arrival')}";
        break;
      case 303:
        message =
        "${AppLocalizations.of(context).translate('303_unable_online_payment')}";
        break;
      case 304:
        message =
        "${AppLocalizations.of(context).translate('304_address_error')}";
        break;
      case 305:
        message =
        "${AppLocalizations.of(context).translate('305_308_balance_insufficient')}";
        break;
      case 306:
        message =
        "${AppLocalizations.of(context).translate('306_account_error')}";
        break;
      case 307:
        message =
        "${AppLocalizations.of(context).translate('307_unable_preorder')}";
        break;
      case 308:
        message =
        "${AppLocalizations.of(context).translate('305_308_balance_insufficient')}";
        break;
      default:
        message =
        "${AppLocalizations.of(context).translate('309_system_error')}";
    }
    _showDialog(
      icon: Icon(FontAwesomeIcons.exclamationTriangle, color: Colors.red),
      message: message,
      isYesOrNo: false,
      context: context
    );
  }
}
void _showOrderSuccessDialog(BuildContext context) {
  /* save the order, in spending ... */
  _playMusicForSuccess();
  _showDialog(
    okBackToHome: true,
    iccon: VectorsData.delivery_nam,
    message:
    "${AppLocalizations.of(context).translate('order_congratz_praise')}",
    isYesOrNo: false,
    context: context
  );
}
Future<void> _playMusicForSuccess() async {
  // play music
  final player = AudioPlayer();
  player.play(MusicData.command_success_hold_on);
  if (await Vibration.hasVibrator()) {
    Vibration.vibrate(duration: 500);
  }
}
