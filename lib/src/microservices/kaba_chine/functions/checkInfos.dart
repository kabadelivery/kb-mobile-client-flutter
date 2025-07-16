import 'package:flutter/cupertino.dart';

import '../data/order/delivery_model.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
Map isFormInfosCorrect({required BuildContext context,required Delivery delivery,required bool generalConditionsAccepted,required bool packageIsSafeConditionAccepted})  {
  // Check if all required fields are filled
  if (delivery.packageName!.isEmpty) {
    return {"is_good":false, "msg":"${AppLocalizations.of(context)!.translate('msg_package_name_missing')}"};
  }
  if(delivery.trackingCode!.isEmpty){
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_tracking_code_missing')}"};
  }
  if (delivery.declaredValue! <= 0) {
    return {"is_good":false, "msg":"${AppLocalizations.of(context)!.translate('msg_declared_value_missing')}"};
  }
  if (delivery.estimatedWeight! <= 0) {
    return {"is_good":false, "msg":"${AppLocalizations.of(context)!.translate('msg_estimated_weight_missing')}"};
  }
  if(delivery.productImage!.isEmpty)
    return {"is_good":false, "msg":"${AppLocalizations.of(context)!.translate('msg_product_image_missing')}"};
  if(delivery.purchaseProofImage!.isEmpty)
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_purchase_proof_image_missing')}"};
  if (delivery.recipientName!.isEmpty) {
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_recipient_name_missing')}"};
  }
  if (delivery.buyerPhoneNumber!.isEmpty) {
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_recipient_phone_missing')}"};
  }
  if(delivery.buyerPhoneNumber!.length<8){
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_phone_invalid_length')}"};
  }

  if(generalConditionsAccepted==false){
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_general_conditions_not_accepted')}"};
  }
  if(packageIsSafeConditionAccepted==false){
    return {"is_good":false, "msg": "${AppLocalizations.of(context)!.translate('msg_package_safety_not_confirmed')}"};
  }
 // If all checks pass, return true
  return {"is_good":true, "msg":"${AppLocalizations.of(context)!.translate('msg_form_valid')}"};

}