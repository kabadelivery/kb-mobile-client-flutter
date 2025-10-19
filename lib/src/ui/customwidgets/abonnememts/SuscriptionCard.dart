
import 'package:KABA/src/ui/customwidgets/abonnememts/SingleSelectList.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionBottomSheet.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionSuccessSheet.dart';
import 'package:KABA/src/ui/screens/home/me/abonnement/kaba_abonnements_actif.dart';
import 'package:KABA/src/ui/screens/home/orders/fake-orderpage/NewDesignOrderPage.dart';
import 'package:flutter/material.dart';
 import 'dart:convert';
 import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../localizations/AppLocalizations.dart';

class SubscriptionCard extends StatelessWidget {

  final int id_pack ;
  final String title;
  final String price;
  double convertprice = 0 ;
  final String currency;
  final Color borderColor;
  final Color accentColor;
  final String livraisons;
  final String validite;
  final String rayon;
  final String min;
  final bool partageable;
  //final List<String> features;
  static int width = 170;
   SubscriptionCard({
    Key? key,
    width,
    required this.id_pack,
    required this.title,
    required this.price,
  
    this.currency = "CFA",
    required this.borderColor,
    required this.accentColor,
    required this.livraisons,
    required this.validite,
    required this.rayon,
    required this.min,
    this.partageable = true,  
  }) : super(key: key);
  
 // 👈 track selection
  @override
  Widget build(BuildContext context) {
    double number = double.parse(price);
   String formatted = NumberFormat("#,###").format(number);
    debugPrint("XXX Price ${price}");
    return Container(
      margin: title == "VIC"
          ? const EdgeInsets.only(left: 35)
          : const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      width: title == "VIC" ? 300 : 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: borderColor, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Row(children: [
            Container(
              color: accentColor.withOpacity(0.1),
              child: Icon(
                title == "BASIC"
                    ? Icons.shield_outlined
                    : title == "BASIC+"
                    ? Icons.bolt_outlined
                    : title == "VIC"
                    ? Icons.verified_outlined
                    : Icons.shield_outlined,
                color: accentColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
          ]),
          const SizedBox(height: 8),

          /// Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatted,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Livraisons
          Row(
            children: [
              Icon(Icons.check, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                "$livraisons ",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                AppLocalizations.of(context)!.translate('deliveries'),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),

          /// Rayon
          Row(
            children: [
              Icon(Icons.check, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.translate('radius_label'),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Text(
                "$rayon Kms",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          /// Min
          Row(
            children: [
              Icon(Icons.check, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.translate('min_label'),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Text(
                "$min F",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          /// Validité
          Row(
            children: [
              Icon(Icons.check, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.translate('valid_label'),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              Text(
                "$validite jours",
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          /// VIC-specific: réduction
          title == "VIC"
              ? Row(children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8ED),
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppLocalizations.of(context)!
                    .translate('vic_discount'),
                style: const TextStyle(
                  fontSize: 13,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ])
              : const SizedBox.shrink(),

          /// VIC-specific: bonus
          title == "VIC"
              ? Row(children: [
            const Icon(Icons.star_border_outlined,
                color: Color(0xFFD99507), size: 18),
            Text(
              AppLocalizations.of(context)!.translate('vic_bonus'),
              style: const TextStyle(
                  fontSize: 13,
                  color: KColors.primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ])
              : const SizedBox.shrink(),

          /// Shareable
          Row(
            children: [
              Icon(Icons.groups_2_outlined, color: accentColor, size: 18),
              const SizedBox(width: 6),
              Text(
                title == "VIC"
                    ? AppLocalizations.of(context)!.translate('shareable_vic')
                    : AppLocalizations.of(context)!.translate('shareable'),
                style:
                const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Subscribe button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                SubscriptionBottomSheet.show(
                  context,
                  idPack: id_pack,
                  title: title,
                  price: number.toString(),
                  livraison: livraisons,
                  validite: validite,
                  rayon: rayon,
                  min: min,
                  currency: "CFA",
                  accentColor: accentColor,
                );
              },
              child: Text(
                AppLocalizations.of(context)!.translate('subscribe'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );

  }

 

/* Future<void> sendPayment(BuildContext context) async {

  final url = Uri.parse("https://c7d355e6cbf7.ngrok-free.app/new_abonnement"); // 👈 replace with your endpoint

  final data = {0
    "user_id": "1958",
    "subscription_id": "12",
    "start_date": "2025-08-28",
    "payement_method": "card",
    "transaction_id": ""
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ success
      SubscriptionSuccessSheet.show(context);
    } else {
      // ❌ failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed")),
      );
    }
  } catch (e) {
    // ❌ error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment failed")),
    );
  }
}
 */


}
