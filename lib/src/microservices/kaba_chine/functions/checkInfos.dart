import 'package:flutter/cupertino.dart';

import '../data/order/delivery_model.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';

import 'package:flutter/material.dart';
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


void showInstructionsPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(

        title: Text(
          AppLocalizations.of(context)!.translate('order'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• "+AppLocalizations.of(context)!.translate('order')),
              const SizedBox(height: 8),
              Text("• "+AppLocalizations.of(context)!.translate('warehouse_instruction')),
              const SizedBox(height: 8),
              Text("• "+AppLocalizations.of(context)!.translate('delivery_request')),
              const SizedBox(height: 8),
              Text("• "+AppLocalizations.of(context)!.translate('customer_service')),
              const SizedBox(height: 8),
              Text("• "+AppLocalizations.of(context)!.translate('office_address')),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            child: Text(
              MaterialLocalizations.of(context).okButtonLabel,
              style: const TextStyle(color: Colors.blue),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

void showShippingCostPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Colors.blue, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.translate("shipping_title"),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Introduction
                sectionTitle(Icons.info, AppLocalizations.of(context)!.translate("shipping_intro_1")),
                sectionText(AppLocalizations.of(context)!.translate("shipping_intro_2")),

                const SizedBox(height: 16),

                // Supplier notes
                sectionTitle(Icons.warning_amber_rounded, AppLocalizations.of(context)!.translate("shipping_supplier_note_1")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_supplier_note_2")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_supplier_note_3")),

                const SizedBox(height: 16),

                // Example
                sectionTitle(Icons.calculate, AppLocalizations.of(context)!.translate("shipping_example_intro")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_example_step_1")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_example_step_2")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_example_step_3")),
                bulletPoint(AppLocalizations.of(context)!.translate("shipping_example_step_4")),

                const SizedBox(height: 16),

                // Final calculation
                sectionTitle(Icons.attach_money, AppLocalizations.of(context)!.translate("shipping_final_calc")),

                const SizedBox(height: 16),

                // Payment info
                sectionTitle(Icons.payment, AppLocalizations.of(context)!.translate("shipping_payment_info_1")),
                sectionText(AppLocalizations.of(context)!.translate("shipping_payment_info_2")),

                const SizedBox(height: 24),

                // Action button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      MaterialLocalizations.of(context).okButtonLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// --- Helper Widgets ---
Widget sectionTitle(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: Colors.blue),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    ],
  );
}

Widget sectionText(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 28, top: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    ),
  );
}

Widget bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.only(left: 28, top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• ", style: TextStyle(fontSize: 14, color: Colors.black87)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    ),
  );
}