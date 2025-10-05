import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SingleSelectList.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionSuccessSheet.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/topups.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; 
 import 'dart:convert';
 import 'package:http/http.dart' as http;
 import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';
 // 👈 import your SingleSelectList file

class SubscriptionBottomSheet extends StatefulWidget {
  final int idPack;
  final String title;
  final String price;
  final String currency;
  final Color accentColor;
  final String livraisons ; 
  final String validite ;
  final String rayon ;
  final String min ; 

  const SubscriptionBottomSheet({
    Key? key,
    required this.idPack,
    required this.title,
    required this.price,
    required this.currency,
    required this.accentColor,
     required this.livraisons,
    required this.validite,
    required this.rayon,
    required this.min,
  }) : super(key: key);

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();

  // 👇 Helper to show it
  static void show(
    BuildContext context, {
    required int idPack,
    required String title,
    required String price,
    required String currency,
    required Color accentColor, required String livraison, required String validite, required String rayon, required String min,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubscriptionBottomSheet(
        idPack: idPack,
        title: title,
        price: price,
        currency: currency,
        accentColor: accentColor,
         livraisons: livraison, 
         validite: validite,
         min: min,
         rayon: rayon,
      ),
    );
  }
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
   int? customerId;
   String? customer_phone = '' ;

  

  int? selectedIndex;
  String? selectedMethodLabel;

  @override
  void initState() {
    super.initState();
    _loadCustomer(); // fetch customer id when bottom sheet opens
  }

  Future<void> _loadCustomer() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    setState(() {
      customerId = customer.id;
      customer_phone = customer.phone_number; // store the user id
    });
  }

 

  // Example items for SingleSelectList
  final items = [
    ListItem(title: "Mobile Money", subtitle: "Mix, MTN, Wave…", icon: Icons.phone_android),
    ListItem(title: "Carte Bancaire", subtitle: "Visa, MasterCard", icon: Icons.credit_card),
    ListItem(title: "PorteFeuille KABA", subtitle: "Votre solde KABA", icon: Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context) {
     double number = double.parse(widget.price);
     String formatted = NumberFormat("#,###").format(number);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER
              const Text(
                "Facture d'abonnement",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Vérifiez les détails de votre abonnement et procédez au paiement sécurisé",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // --- SUBSCRIPTION DETAILS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.accentColor.withOpacity(0.1),
                  border: Border.all(color: widget.accentColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(formatted+""+ "${widget.currency}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCD1F45),
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(children:  [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text(widget.livraisons+" Livraisons"),
                    ]),
                    Row(children:  [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Valide ${widget.livraisons} jours"),
                    ]),
                    Row(children:  [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Rayon de ${widget.rayon} Kms"),
                    ]),
                    Row(children:  [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Min. ${widget.min} F"),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- FACTURATION DETAILS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Détails de la facturation",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Prix de base"),
                        Text("${formatted}"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 15),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total a Payer"),
                        Text("${formatted}",style: TextStyle(color: KColors.primaryColor),),
                      ],
                    )
                  ,
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- PAYMENT METHODS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Choisissez la méthode de paiement",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // --- SingleSelectList
                    SingleSelectList(
                      items: items,
                      onChanged: (i) {
                        setState(() => selectedIndex = i);
                      },
                      onItemSelected: (label) {
                        setState(() => selectedMethodLabel = label);
                      },
                    ),

                    const Divider(),

                    // --- Selected Method Display
                    if (selectedMethodLabel != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Text(
                          selectedMethodLabel!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                      )
                    else
                      const Text("Veuillez sélectionner une méthode 👆",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- ACTION BUTTONS
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD1F45),
                    ),
                    onPressed: () async {
                      if (selectedMethodLabel == null) {
                       debugPrint("No Payement Selected");
                      }
                     
                     // debugPrint("Pay with $selectedMethodLabel , abo_id:${widget.idPack} , price:${widget.price} , customer id ${customerId }");
                     ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Traitement en cours..."),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
                   
                  var response = await sendSubscriptiondata(
    '$customerId',
    '${widget.idPack}',
    "$selectedMethodLabel",
    "${widget.price}",
  );
  
   if (response['status'] == "success") {
    
   Navigator.pop(context);
    await Future.delayed(const Duration(seconds: 5));
    SubscriptionSuccessSheet.show(context);

  } else {
   Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text( response['message']),
        backgroundColor: Colors.red,
      ),
    );
  } 
                    },
                    child: const Text("Payer ",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
   Future<Map<String, dynamic>> sendSubscriptiondata(
  String userid,
  String suscription_id,
  String payement_method,
  String price,
) async {
  try {
    final response = await http.post(
      Uri.parse(ServerRoutes.KABA_ABONNEMENT_NEW_ABONNEMENT),
      body: {
        "user_id": userid,
        "subscription_id": suscription_id,
        "start_date": DateTime.now().toIso8601String().split("T").first, // "YYYY-MM-DD"
        "payement_method": payement_method,
        "transaction_id": " ",
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // ✅ If payment processor succeeds
      await PaymentProcessor.processPayment(
        method: payement_method,
        price: double.parse(price),
      );

      return {
        "status": "success",
        "message": "Paiement réussi",
        "data": response.body,
      };
    } else {
      
      print("Error: ${response.statusCode}, body: ${response.body}");
      return {
        "status": "error",
        "message": "Desole vous deja un Abonnement en cours !",
        "code": response.statusCode,
      };
    }
  } catch (e) {
    print("Exception: $e");
    return {
      "status": "error",
      "message": "Exception: $e",
    };
  }
}

}


enum PaymentCategory { flooz, internationaux, card, unsupported, local }

class PaymentProcessor {
  // 👉 Groupes de moyens de paiement
  static final List<String> local = ["flooz","mix"];
  static final List<String> internationaux = ["mtn", "wave"];
  static final List<String> cards = ["visa", "mastercard", "american"];

  // 🔹 Convertir une string en catégorie
  static PaymentCategory getCategory(String method) {
    final normalized = method.toLowerCase();

    if (local.contains(normalized)) return PaymentCategory.local;
    if (internationaux.contains(normalized)) return PaymentCategory.internationaux;
    if (cards.contains(normalized)) return PaymentCategory.card;
    return PaymentCategory.unsupported;
  }

  static Future<Map<String, dynamic>> processPayment({
    required String method,
    required double price,
  }) async {
    final category = getCategory(method);

    switch (category) {
    case PaymentCategory.local:
      return await launchNewMomoTopUp(price);

    case PaymentCategory.internationaux:
      return {"status": "error", "message": "Méthode internationale pas encore implémentée"};

    case PaymentCategory.card:
      return await launchNewCardTopUp(price);

    case PaymentCategory.unsupported:
      return {"status": "error", "message": "Méthode non supportée"};

    case PaymentCategory.flooz:
      return {"status": "error", "message": "Flooz direct non implémenté"};
  }
  }

  // 🔹 Méthodes privées
  static Future<Map<String, dynamic>> launchNewMomoTopUp(double price) async {
  
    ClientPersonalApiProvider provider = new ClientPersonalApiProvider();
    CustomerModel customer = await CustomerUtils.getCustomer();
    bool launch_other_payment = false ;
    String? user_phone_number = customer.phone_number ;
    String abo_price = price.toString() ;
    bool isMomoFromTogo   = await detectTogoMomoOperator(user_phone_number!);
    if(!isMomoFromTogo){
       
    }
    if(!launch_other_payment){
      try {
    Map result = await provider.launchTopUp(customer, user_phone_number!, price.toString(), 0.0 , 2);
    debugPrint('result $result');

    if (result != null && result['error'] == 0) {
      return {"status": "success", "message": "Paiement réussi", "data": result};
    } else {
      return {"status": "error", "message": "Échec du paiement", "data": result};
    }
  } catch (e) {
    return {"status": "error", "message": "Exception: $e"};
  }
} 
    }
   
    /*
    *     if(launch_other_payment){
      KkiapayProvider kkiapayProvider = new KkiapayProvider();
      kkiapayProvider.launchKkiapayPayment(
        context,
        amount:int.parse(_amountFieldController!.text),
        customer: customer,
        phone_number: _phoneNumberFieldController!.text,
        feesAmount: _getFees(), typeOfTransaction: 'momo',
        );
    }
*/
  }

  
    /*
    * if(launch_other_payment){
      KkiapayProvider kkiapayProvider = new KkiapayProvider();
      String picked_card = bankPaymentModes.where((element) => element["id"]==bank_picked_id).first['name'];;
      kkiapayProvider.launchKkiapayPayment(
        context,
        amount:int.parse(_amountFieldController!.text),
        customer: customer,
        selectedCard: picked_card,
        feesAmount: _getFees(),
        typeOfTransaction: 'card',
      );
      setState(() {
        showLoading(true);
      });
    }*/
    Future<Map<String, dynamic>> launchNewCardTopUp(double price) async {
  bool launch_other_payment = false;
  ClientPersonalApiProvider provider = new ClientPersonalApiProvider();
  CustomerModel customer = await CustomerUtils.getCustomer();
  Map<String, dynamic> semoaResult = {};

  try {
    debugPrint("_getRealInitialAmountFromTotal ");
    Map<String, dynamic> paymentData = {
      "amount": price,
      "description": "Paiement Abonnement",
      "user": {
        "lastname": "${customer.nickname}",
        "firstname": "",
        "phone": "${customer.username}",
      }
    };
    semoaResult = await provider.launchSemoa(customer, paymentData);
  } catch (_) {
    launch_other_payment = true;
  }

  if (semoaResult != null && semoaResult.isNotEmpty) {
    debugPrint('semoaResult $semoaResult');
    if (semoaResult['order_reference'] != null) {
      Map<String, dynamic> semoaData = semoaResult;
      List<dynamic> paymentsMethods = semoaData['payments_method'] ?? [];
      String orderReference = semoaData['order_reference'] ?? '';
      Map<String, dynamic> semoaStoreData = {
        'transaction_id': orderReference,
        'amount': price,
        'user_id': customer?.id,
        'fees': '',
        'details': 'Paiement pour Abonnement',
        'transaction_motif_id': 2
      };
      Map result = await provider.launchStoreSemoaTransaction(customer, semoaStoreData);
      debugPrint('paymentsMethods: $paymentsMethods');

      if (result != null && result['data']['success'] && paymentsMethods.isNotEmpty) {
        Map<String, dynamic>? firstPaymentMethod;
        if (paymentsMethods.isNotEmpty && paymentsMethods[0] is List) {
          List<dynamic> firstGroup = paymentsMethods[0];
          if (firstGroup.isNotEmpty) {
            firstPaymentMethod = firstGroup[0];
          }
        }

        if (firstPaymentMethod != null) {
          String actionUrl = firstPaymentMethod['action'] ?? '';
          String gatewayName = firstPaymentMethod['gateway'] ?? 'Unknown';
          String description = firstPaymentMethod['description'] ?? '';

          if (firstPaymentMethod['gateway'].toString().contains("Ecobank-Semoa")) {
            var textActionSemoaAvailable = true;
            var textActionSemoa = firstPaymentMethod['action'];
          }

          if (actionUrl.isNotEmpty && actionUrl.contains('https')) {
            final uri = Uri.parse(actionUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return {
                "status": "success",
                "message": "Paiement carte initié",
                "data": semoaResult
              };
            } else {
              launch_other_payment = true;
            }
          }
        }
      }
    } else {
      CherryToast.error(
        title: Text("Error"),
        description: Text("Error"),
        autoDismiss: true,
      );
      launch_other_payment = true;
    }
  }

  // ✅ Default return to satisfy Dart
  return {
    "status": "error",
    "message": "Impossible d’initier le paiement",
    "data": {}
  };
}

    
    
     
/// Sends JSON data to an endpoint and returns true if successful, false otherwise.


 