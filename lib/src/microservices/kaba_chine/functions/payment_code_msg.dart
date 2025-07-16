import 'package:KABA/src/microservices/kaba_chine/Enums/paymentState.dart';
import 'package:flutter/cupertino.dart';

import '../../../localizations/AppLocalizations.dart';

String paymentStateMessage({required BuildContext context,required int code}){
  String msg = "";

  switch(code){
    case 100:
      msg = "${AppLocalizations.of(context)!.translate('payment_successful')}";
      break;
    case 101:
      msg = "${AppLocalizations.of(context)!.translate('payment_error')}";
      break;
      case 102:
        msg ="${AppLocalizations.of(context)!.translate('not_enough_to_pay')}";
        break;
    default:
      msg = "";
      break;
  }
  return msg;
}