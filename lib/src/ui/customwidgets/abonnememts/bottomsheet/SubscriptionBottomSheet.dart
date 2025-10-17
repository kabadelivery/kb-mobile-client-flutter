// Paste this file replacing your current SubscriptionBottomSheet.dart
import 'dart:convert';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/resources/client_personal_api_provider.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SingleSelectList.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/bottomsheet/SubscriptionSuccessSheet.dart';
import 'package:KABA/src/ui/screens/home/me/abonnement/kaba_abonnements.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/topups.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

// <-- Adjust this import if your KkiapayProvider is elsewhere
import 'package:KABA/src/resources/kkiapay_provider.dart';

import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';

import '../../../../contracts/transaction_contract.dart';
import '../../../screens/home/me/abonnement/kaba_abonnements.dart';

class SubscriptionBottomSheet extends StatefulWidget {
  final int idPack;
  final String title;
  final String price;
  final String currency;
  final Color accentColor;
  final String livraisons;
  final String validite;
  final String rayon;
  final String min;

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

  static void show(
      BuildContext context, {
        required int idPack,
        required String title,
        required String price,
        required String currency,
        required Color accentColor,
        required String livraison,
        required String validite,
        required String rayon,
        required String min,
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
  String? customer_phone = '';
  bool isProcessing = false;

  int? selectedIndex;
  String? selectedMethodLabel;
  var fees = 0;

  double? fees_tmoney = 4.0;

  double? fees_flooz = 4.0;

  double? fees_bankcard = 5.0;
  double? fees_momo = 4.0;
  final items = [
    ListItem(
        title: "Mobile Money",
        subtitle: "Mix, MTN, Wave…",
        icon: Icons.phone_android),
    ListItem(
        title: "Carte Bancaire",
        subtitle: "Visa, MasterCard",
        icon: Icons.credit_card),
    ListItem(
        title: "PorteFeuille KABA",
        subtitle: "Votre solde KABA",
        icon: Icons.account_balance_wallet),
  ];
  void getFees()async{
    CustomerModel customer = await CustomerUtils.getCustomer();
    ClientPersonalApiProvider provider =ClientPersonalApiProvider();
    var fees_obj = await provider.fetchFees(customer);
     fees_flooz = double.parse("${fees_obj["fees_flooz"]}");
     fees_tmoney = double.parse("${fees_obj["fees_tmoney"]}");
     fees_bankcard = double.parse("${fees_obj["fees_bankcard"]}");
  }
  double calculateAmountWithFees(){
    double amount = double.parse(widget.price);
    if (selectedMethodLabel == "Mobile Money") {
      amount = amount + fees_momo!;
    } else if (selectedMethodLabel == "Carte Bancaire") {

    }

    return amount;
  }
  @override
  void initState() {
    super.initState();
    _loadCustomer();
    getFees();
  }

  Future<void> _loadCustomer() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    setState(() {
      customerId = customer.id;
      customer_phone = customer.phone_number;
    });
  }

  void showProcessingBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text("Traitement en cours..."),
          ],
        ),
      ),
    );
  }

  /// Launch Kkiapay as a fallback or direct gateway
  Future<void> _launchKkiapayPayment({
    required BuildContext context,
    required int amount,
    required String customerNickname,
    required String typeOfTransaction,
    String selectedCard = 'card',
  }) async {
    try {
      CustomerModel  cusModel = await CustomerUtils.getCustomer();
      KkiapayProvider kkiapayProvider = new KkiapayProvider();
      debugPrint("Amount $amount");
      kkiapayProvider.launchKkiapayPayment(
        context,
        amount: amount,
        customer: cusModel,
        selectedCard: selectedCard,
        feesAmount: 0,
        typeOfTransaction: typeOfTransaction,
        phone_number: cusModel.phone_number,
      );
    } catch (e) {
      debugPrint('Kkiapay launch error: $e');
    }
  }

  /// Ask the user to pick the mobile money operator (Mix, Flooz, Moov, MTN, Wave)
  Future<String?> _selectMomoOperatorDialog() async {
    String? picked;
    final options = <Map<String, String>>[
      {'label': 'Mix', 'value': 'mix'},
      {'label': 'Flooz', 'value': 'flooz'},
      {'label': 'Moov Togo', 'value': 'moov'},
      {'label': 'MTN', 'value': 'mtn'},
      {'label': 'Wave', 'value': 'wave'},
    ];

    await showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((op) {
              return ListTile(
                title: Text(op['label']!),
                onTap: () {
                  picked = op['value'];
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    double number = double.tryParse(widget.price) ?? 0.0;
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
              // subscription card
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
                        Text(formatted + "" + "${widget.currency}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCD1F45),
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 6),
                      Text("${widget.livraisons} Livraisons"),
                    ]),
                    Row(children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 6),
                      Text("Valide ${widget.validite} jours"),
                    ]),
                    Row(children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 6),
                      Text("Rayon de ${widget.rayon} Kms"),
                    ]),
                    Row(children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 6),
                      Text("Min. ${widget.min} F"),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Billing details
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
                        Text("${formatted}",
                            style: TextStyle(color: KColors.primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // payment methods
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
                    SingleSelectList(
                      items: items,
                      onChanged: (i) {
                        setState(()  {
                          selectedIndex = i;
                          isProcessing=false;
                        });

                      },
                      onItemSelected: (label) {
                        setState(() => selectedMethodLabel = label);
                      },
                    ),
                    const Divider(),
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
              // actions
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD1F45),
                    ),
                    onPressed: isProcessing
                        ? null
                        : () async {
                      if (selectedMethodLabel == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                            Text("Veuillez sélectionner un mode de paiement."),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      // Handle submission depending on selected method
                      setState(() => isProcessing = true);

                      String? methodToSend;

                      if (selectedMethodLabel == "Mobile Money") {
                        final op = await _selectMomoOperatorDialog();
                        if (op == null) {
                          setState(() => isProcessing = false);
                          return;
                        }
                        methodToSend = op; // 'mix','flooz','moov','mtn','wave'
                      } else if (selectedMethodLabel == "Carte Bancaire") {
                        methodToSend = 'card';
                      } else if (selectedMethodLabel == "PorteFeuille KABA") {
                        methodToSend = 'portefeuille';
                      } else {
                        methodToSend = selectedMethodLabel!.toLowerCase();
                      }

                      debugPrint(
                          "Pay with $methodToSend , abo_id:${widget.idPack} , price:${widget.price} , customer id ${customerId }");

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Traitement en cours..."),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 10),
                        ),
                      );
                     await checkPaymentStatus(context);
                      await sendSubscriptiondata(
                        context,
                        '$customerId',
                        '${widget.idPack}',
                        methodToSend!,
                        "${widget.price}",
                      );
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

  /// Orchestrator: send subscription -> choose payment path -> check status -> update backend
  Future<Map<String, dynamic>?> sendSubscriptiondata(
      BuildContext context,
      String userid,
      String suscription_id,
      String payement_method,
      String price,
      ) async {
    try {
      // 1) Create subscription record on backend
      final response = await http.post(
        Uri.parse(ServerRoutes.KABA_ABONNEMENT_NEW_ABONNEMENT),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userid,
          "subscription_id": suscription_id,
          "start_date": DateTime.now().toIso8601String().split("T").first,
          "payement_method": payement_method,
          "transaction_id": "",
          "price": price,
        }),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint("❌ Error during subscription insert: ${response.body}");
        return {
          "status": "error",
          "message": "Échec de l'enregistrement de l'abonnement.",
        };
      }

      // If the user chose portefeuille, call wallet endpoint and return result immediately
      if (payement_method.toLowerCase() == 'portefeuille') {
        final res = await paySubscriptionWithWallet(
          context,
          int.tryParse(userid) ?? (customerId ?? 0),
          double.tryParse(price) ?? 0.0,
          suscription_id,
        );
        // paySubscriptionWithWallet returns a Map
        return res;
      }

      // For international momo (mtn, wave) -> use Kkiapay directly
      final lower = payement_method.toLowerCase();
      debugPrint("XXX PAYMENT METHOD ${lower}");
      if (lower !="flooz" && lower!="mix") {
        final customer = await CustomerUtils.getCustomer();
        debugPrint("amount ${double.parse(price)}");
        await _launchKkiapayPayment(
          context: context,
          amount: (double.parse(price)).toInt(),
          customerNickname: customer.nickname ?? '',
          typeOfTransaction: 'momo',
        );
      }
      final procResult = await PaymentProcessor.processPayment(
        method: payement_method,
        price: double.tryParse(price) ?? 0.0,
      );

      // if primary succeeded -> wait then check status
      if (procResult['status'] == 'success') {
        // Give backend some time to process the payment callback
       Navigator.pop(context);
      } else {
        // primary method failed -> fallback to Kkiapay
        debugPrint('Primary payment method failed: ${procResult['message']} - launching Kkiapay fallback');
        debugPrint("amount ${double.parse(price)}");
        final customer = await CustomerUtils.getCustomer();
        await _launchKkiapayPayment(
          context: context,
          amount: (double.parse(price)).toInt(),
          customerNickname: customer.nickname ?? '',
          typeOfTransaction:
          (payement_method.toLowerCase() == 'card') ? 'card' : 'momo',
        );
      }
    } catch (e) {
      debugPrint("Exception in sendSubscriptiondata: $e");
      return {
        "status": "error",
        "message": "Exception: $e",
      };
    }
  }



  // Wallet payment now returns a Map result for the orchestrator to handle
  Future<Map<String, dynamic>> paySubscriptionWithWallet(
      BuildContext context,
      int userId,
      double amount,
      String subscriptionId,
      ) async {
    try {
      final url = Uri.parse(ServerRoutes.LINK_PAY_BY_WALLET);

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "amount": amount,
          "subscription_id": subscriptionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 1) {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 16),
                    const Text(
                      "Paiement Réussi 🎉",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Votre abonnement a été payé avec succès via le portefeuille.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Kaba_abonnement(
                              presenter: TransactionPresenter(TransactionView()),
                            ),
                          ),
                        );
                      },
                      child:
                      const Text("Fermer", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          );
          return {"status": "success", "message": "Paiement portefeuille OK"};
        } else {
          _showError(context, "Erreur lors du paiement. Veuillez réessayer.");
          return {"status": "error", "message": "Erreur paiement portefeuille"};
        }
      } else {
        _showError(context, "Erreur serveur (${response.statusCode})");
        return {"status": "error", "message": "Erreur serveur"};
      }
    } catch (e) {
      _showError(context, "Une erreur s'est produite: $e");
      return {"status": "error", "message": "Exception: $e"};
    }
  }

  void _showError(BuildContext context, String message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color:KColors.primaryColor, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Échec du paiement",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Fermer", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Payment processor helpers (keeps your existing provider usage)
enum PaymentCategory { flooz, internationaux, card, unsupported, mix, portefeuille }

class PaymentProcessor {
  static final List<String> mix = ["mix"];
  static final List<String> flooz = ["flooz"];
  static final List<String> internationaux = ["mtn", "wave"];
  static final List<String> cards = ["visa", "mastercard", "american", "card"];
  static final List<String> portefeuille = ["portefeuille"];

  static PaymentCategory getCategory(String method) {
    final normalized = method.toLowerCase();
    if (mix.contains(normalized)) return PaymentCategory.mix;
    if (internationaux.contains(normalized)) return PaymentCategory.internationaux;
    if (cards.contains(normalized)) return PaymentCategory.card;
    if (portefeuille.contains(normalized)) return PaymentCategory.portefeuille;
    return PaymentCategory.unsupported;
  }

  static Future<Map<String, dynamic>> processPayment({
    required String method,
    required double price,
  }) async {
    final category = getCategory(method);

    switch (category) {
      case PaymentCategory.mix:
        return await launchNewMomoTopUp(price);
      case PaymentCategory.internationaux:
      // For internationals we expect to be launched via Kkiapay - let orchestrator handle it.
        return {"status": "error", "message": "International -> use Kkiapay"};
      case PaymentCategory.card:
        return await launchNewCardTopUp(price);
      case PaymentCategory.portefeuille:
      // handled by orchestration (we kept it separate)
        return {"status": "error", "message": "Portefeuille handled separately"};
      case PaymentCategory.flooz:
        return await launchNewMomoTopUp(price);
      case PaymentCategory.unsupported:
      default:
        return {"status": "error", "message": "Méthode non supportée"};
    }
  }

  static Future<Map<String, dynamic>> launchNewMomoTopUp(double price) async {
    ClientPersonalApiProvider provider = ClientPersonalApiProvider();
    CustomerModel customer = await CustomerUtils.getCustomer();
    String? user_phone_number = customer.phone_number;
    bool launch_other_payment = false;

    // If detectTogoMomoOperator exists and returns whether it's local; keep it if available
    try {
      bool isMomoFromTogo = true;
      if (user_phone_number != null) {
        isMomoFromTogo =
        await detectTogoMomoOperator(user_phone_number); // keep existing helper if present
      }
      // If not local, indicate failure to make orchestration fallback to Kkiapay
      if (!isMomoFromTogo) {
        return {"status": "error", "message": "Momo non local - use Kkiapay"};
      }
    } catch (e) {
      debugPrint("detectTogoMomoOperator error: $e");
      // ignore detection error and attempt provider
    }

    try {
      Map result = await provider.launchTopUp(
          customer, user_phone_number ?? '', price.toString(), 0.0, 2);
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

  static Future<Map<String, dynamic>> launchNewCardTopUp(double price) async {
    ClientPersonalApiProvider provider = ClientPersonalApiProvider();
    CustomerModel customer = await CustomerUtils.getCustomer();

    try {
      Map<String, dynamic> paymentData = {
        "amount": price,
        "description": "Paiement Abonnement",
        "user": {
          "lastname": "${customer.nickname}",
          "firstname": "",
          "phone": "${customer.username}",
        }
      };
      final semoaResult = await provider.launchSemoa(customer, paymentData);

      if (semoaResult != null && semoaResult.isNotEmpty) {
        if (semoaResult['order_reference'] != null) {
          List<dynamic> paymentsMethods = semoaResult['payments_method'] ?? [];
          if (paymentsMethods.isNotEmpty) {
            Map<String, dynamic>? firstPaymentMethod;
            if (paymentsMethods[0] is List) {
              List<dynamic> firstGroup = paymentsMethods[0];
              if (firstGroup.isNotEmpty) firstPaymentMethod = firstGroup[0];
            } else if (paymentsMethods[0] is Map) {
              firstPaymentMethod = paymentsMethods[0];
            }

            if (firstPaymentMethod != null) {
              final actionUrl = firstPaymentMethod['action'] ?? '';
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
                  return {"status": "error", "message": "Impossible d'ouvrir la page de paiement"};
                }
              }
            }
          }
        }
      }
      return {"status": "error", "message": "Impossible d’initier le paiement"};
    } catch (e) {
      return {"status": "error", "message": "Exception: $e"};
    }
  }
}
