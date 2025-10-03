import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/utils.dart';
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconPoint(Icons.shopping_cart, AppLocalizations.of(context)!.translate('order')),
              const SizedBox(height: 8),
              _buildIconPoint(Icons.warehouse, AppLocalizations.of(context)!.translate('warehouse_instruction')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: () {
                    showAddressPopup(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: KabaChineColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.translate('click_here'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildIconPoint(Icons.local_shipping, AppLocalizations.of(context)!.translate('delivery_request')),
              const SizedBox(height: 8),
              _buildIconPoint(Icons.support_agent, AppLocalizations.of(context)!.translate('customer_service')),
              const SizedBox(height: 8),
              _buildIconPoint(Icons.location_city, AppLocalizations.of(context)!.translate('office_address')),
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
Widget _buildIconPoint(IconData icon, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.blue, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ),
    ],
  );
}
void showAddressPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.grey.shade100.withOpacity(0.95), // gris clair transparent
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
               "${AppLocalizations.of(context)!.translate('address')}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              _buildAddressRow(context, Icons.location_on, "${AppLocalizations.of(context)!.translate('location')}", "${AppLocalizations.of(context)!.translate('city_china')}"),
              const SizedBox(height: 12),

              _buildAddressRow(context, Icons.home, "${AppLocalizations.of(context)!.translate('address')}",  "${AppLocalizations.of(context)!.translate('adresse_china')}"),
              const SizedBox(height: 12),

              _buildAddressRow(context, Icons.person, "${AppLocalizations.of(context)!.translate('name')}", "${AppLocalizations.of(context)!.translate('name_adresse_china')}"),
              const SizedBox(height: 12),

              _buildAddressRow(context, Icons.phone, "${AppLocalizations.of(context)!.translate('contact')}", "(86) 18688424896"),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildAddressRow(BuildContext context, IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.blue, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(

                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
      IconButton(
        icon: const Icon(Icons.copy, color: Colors.blue, size: 20),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: value));
          Fluttertoast.showToast(msg: '${AppLocalizations.of(context)!.translate('copied_c')}', toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER);
        },
      ),
    ],
  );
}

void showShippingCostPopup(BuildContext context,String price) {
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
                sectionTitle(Icons.attach_money, AppLocalizations.of(context)!.translate("shipping_final_calc1")+"$price FCFA"+AppLocalizations.of(context)!.translate("shipping_final_calc2")),

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