
import 'package:KABA/src/ui/customwidgets/abonnememts/SingleSelectList.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionBottomSheet.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionSuccessSheet.dart';
import 'package:KABA/src/ui/screens/home/me/abonnement/kaba_abonnements_actif.dart';
import 'package:KABA/src/ui/screens/home/orders/fake-orderpage/NewDesignOrderPage.dart';
import 'package:flutter/material.dart';
 import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionCard extends StatelessWidget {

  final int id_pack ;
  final String title;
  final String price;
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
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      width: width.toDouble() == 0 ? 170 : width.toDouble(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: borderColor, width: 2),
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
           // borderRadius: BorderRadius.circular(4),
            color: accentColor.withOpacity(0.1),
            child:Icon(Icons.shield_outlined, color: accentColor, size: 18),
           ),
           SizedBox(width: 6),
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
                price,
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

          /// Features list
              Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                   Text(
                      "$livraisons  ",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87,fontWeight: FontWeight.bold),
                    ),
                  Text(
                      "Livraisons",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                ],
              ),
               Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                   Text(
                      "Rayon de ",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87,),
                    ),
                  Text(
                      "$rayon Kms",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87 , fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                   Text(
                      "Min . ",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87,),
                    ),
                  Text(
                      "$min F",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87 , fontWeight: FontWeight.bold),
                    ),
                ],
              ),
                Row(
                children: [
                  Icon(Icons.check, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                   Text(
                      "Valide  ",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87,),
                    ),
                  Text(
                      "$validite jours",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87 , fontWeight: FontWeight.bold),
                    ),
                ],
              ),
               Row(
                children: [
                   Icon(Icons.groups_2_outlined, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                   Text(
                       partageable ? "Partageable" : "non partageable",
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87,),
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
      idPack:id_pack ,
      title: title,
      price: price.toString(),
      currency: "CFA",
      accentColor: Colors.red,
    );
  },
              child: const Text(
                "S'abonner",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

 

/* Future<void> sendPayment(BuildContext context) async {

  final url = Uri.parse("https://eb866e86b8d4.ngrok-free.app/new_abonnement"); // 👈 replace with your endpoint

  final data = {
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
