import 'dart:convert';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SuscriptionCard.dart';
import 'package:KABA/src/utils/_static_data/ServerConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:KABA/src/utils/_static_data/ServerRoutes.dart';

class Kaba_abonnement extends StatefulWidget {
  static var routeName = "/Kaba_abonnement";
  final CustomerModel? customer;

  const Kaba_abonnement(
      {Key? key, this.customer, required TransactionPresenter presenter})
      : super(key: key);

  @override
  _Kaba_abonnementState createState() => _Kaba_abonnementState();
}

class _Kaba_abonnementState extends State<Kaba_abonnement> {
  Map<String, dynamic>? subscriptionData;
  bool isLoadingSubscription = true;
  bool subscriptionFetchFailed = false;

  List<Map<String, dynamic>> subscriptionPlans = [];
  bool isLoadingPlans = true;

  int? customerId; // Customer ID

  @override
  void initState() {
    super.initState();
    _initData();
    _fetchSubscriptionPlans();
  }

  // ------------------- Initialize Data -------------------
  Future<void> _initData() async {
    // 1️⃣ Load customer
    await _loadCustomer();

    if (customerId == null) {
      setState(() {
        isLoadingSubscription = false;
        subscriptionFetchFailed = true;
      });
     /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Customer ID not found.")),
      );*/
      return;
    }

    setState(() {
      isLoadingSubscription = true; // show loading until subscription is confirmed
    });

    // 2️⃣ Check and update subscription

    final result = await checkAndUpdateSubscription(customerId!);

    // 3️⃣ Refetch subscription to ensure latest status
    await _fetchSubscription();

    // 4️⃣ Fetch subscription plans


    if (mounted) {
      setState(() {
        isLoadingSubscription = false;
      });
     /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🔔 ${result["message"]}")),
      );*/
    }
  }


  // ------------------- Load Customer -------------------
  Future<void> _loadCustomer() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    setState(() {
      customerId = customer.id;
    });
  }






  // ------------------- Fetch Current Subscription -------------------
  Future<void> _fetchSubscription() async {
    if (customerId == null) {
      print("⚠️ No customer ID provided.");
      setState(() {
        subscriptionData = null;
        isLoadingSubscription = false;
        subscriptionFetchFailed = true;
      });
      return;
    }

    final url = Uri.parse(
      "${ServerRoutes.KABA_ABONNEMENT_SUSCRIBED_USER}/$customerId",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final rawData = json.decode(response.body);

        if (rawData is! Map<String, dynamic>) {
          throw Exception("Unexpected response format: not a JSON object");
        }

        // ✅ Safe normalization of values to String
        Map<String, dynamic> normalizedData = Map<String, dynamic>.from(rawData);

        normalizedData["subscription_id"] =
            (rawData["subscription_id"] ?? "").toString();
        normalizedData["end_date"] = (rawData["end_date"] ?? "").toString();
        normalizedData["codeAbonnement"] =
            (rawData["codeAbonnement"] ?? "").toString();
        normalizedData["deliveriesUsed"] =
            (rawData["deliveriesUsed"] ?? "0").toString();
        normalizedData["deliveriesTotal"] =
            (rawData["deliveriesTotal"] ?? "0").toString();

        if (!mounted) return;

        setState(() {
          subscriptionData = normalizedData;
          isLoadingSubscription = false;
        });
      } else {
        throw Exception("Failed to fetch subscription for customer $customerId");
      }
    } catch (e) {
      print("❌ Error fetching subscription for $customerId: $e");
      if (!mounted) return;
      setState(() {
        subscriptionData = null;
        subscriptionFetchFailed = true;
        isLoadingSubscription = false;
      });
    }
  }


  // ------------------- Fetch Available Plans -------------------
  Future<void> _fetchSubscriptionPlans() async {
    final url = Uri.parse(ServerRoutes.KABA_ABONNEMENT_GET_PACKS);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          subscriptionPlans = List<Map<String, dynamic>>.from(data);
          isLoadingPlans = false;
        });
      } else {
        throw Exception("Failed to fetch subscription plans");
      }
    } catch (e) {
      print("Error fetching subscription plans: $e");
      if (!mounted) return;
      setState(() {
        subscriptionPlans = [];
        isLoadingPlans = false;
      });
    }
  }


  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  Future<void> _validateAndSendCode() async {
    final code = _codeController.text.trim();

    if (code.length != 6) {
      _showModal("Code invalide", "Veuillez entrer un code à 6 chiffres.");
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse(ServerRoutes.KABA_ABONNEMENT_SHARING_CODE_USER),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": customerId.toString(),
          "Code": code
        }),
      );

      setState(() => _loading = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print(response.body);
        Navigator.pop(context);
        _codeController.clear();

        // 🆕 ADDED: Wait 5 seconds then refresh subscription and UI
        setState(() => isLoadingSubscription = true);
        await Future.delayed(Duration(seconds: 3));

        // ✅ Immediately refresh subscription *after* modal is closed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Kaba_abonnement(
              presenter: TransactionPresenter(TransactionView()),
            ),
          ),
        );

        _refreshPage();



      } else {
        try {
          print(response.body);
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody["message"] ?? "Une erreur inconnue est survenue";
          _showModal("Erreur", errorMessage);
        } catch (e) {
          _showModal("Error lors du partage du Code ! ", 'lo');
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      _showModal("Erreur", "Une erreur est survenue. Réessayez.");
    }
  }


  void _refreshPage() {
    setState(() {});
  }

  void _showModal(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }



void _showAddBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.text,
                    maxLength: 7,
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "Entrer le code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _loading ? null : _validateAndSendCode,
                  child: _loading
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text("Valider", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Entrez ici le code d'abonnement qui vous éte partagé !(Code a Six Chiffres) .",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    },
  );
}

  // ------------------- Check & Update Subscription -------------------
  Future<Map<String, dynamic>> checkAndUpdateSubscription(int? userId) async {
     String user_id = userId.toString();
    final checkUrl = Uri.parse("https://dev.pay.kaba-delivery.com/api/check/subscription"); // Server A
    final updateUrl = Uri.parse(ServerRoutes.KABA_UPDATE_PAYMENT_STATUS_ABO);    // Server B

    try {
      // STEP 1: Ask Server A about payment/subscription state
      final checkResponse = await http.post(
        checkUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": user_id}),
      ).timeout(const Duration(seconds: 6));

      if (checkResponse.statusCode == 200 && checkResponse.body.isNotEmpty) {
        final checkData = jsonDecode(checkResponse.body);
        print("✅ Server A response: $checkData");

        final state = checkData["state"];
        if (state == 1) {
          // STEP 2: Payment is successful, notify Server B to update subscription
          final updateResponse = await http.post(
            updateUrl,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "user_id": user_id,
              "status_payement": 1,
              "status_abonnement": 1,
              "transaction_id": checkData["transaction_id"] ?? "0", // optional
            }),
          ).timeout(const Duration(seconds: 15));

          if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) {
            final updateData = jsonDecode(updateResponse.body);
            print("🟢 Server B subscription updated: $updateData");

            // ⏳ Poll up to 5 times (every 2s) until subscription data changes
            bool updated = false;
            for (int i = 0; i < 5; i++) {
              print("🔁 Checking updated subscription (try ${i + 1}/5)...");
              await Future.delayed(Duration(seconds: 2));
              await _fetchSubscription();

              // if backend marks it as active or data changes, break loop
              if (subscriptionData != null &&
                  (subscriptionData!["status_abonnement"] == 1 ||
                      subscriptionData!["end_date"] != null)) {
                updated = true;
                break;
              }
            }

            print(updated
                ? "✅ Subscription successfully refreshed"
                : "⚠️ No change detected after waiting");

            return {"success": true, "message": "Subscription updated successfully"};
          } else {
            print("❌ Server B update failed: ${updateResponse.statusCode}");
            return {"error": true, "message": "Failed to update subscription"};
          }

        } else {
          print("⚠️ Payment not confirmed for user $userId");
          return {"status": "pending", "message": "Payment not yet confirmed"};
        }
      } else {
        print("❌ Invalid response from Server A: ${checkResponse.statusCode}");
        return {"error": true, "message": "Failed to fetch payment status"};
      }
    } catch (e) {
      print("🔥 Error in checkAndUpdateSubscription for $userId: $e");
      return {"error": true, "message": e.toString()};
    }
  }



  // ------------------- Active Subscription Card -------------------
  Widget _buildActiveCard(Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 10),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/png/abonnement-icons/Package.png",
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Mon abonnement\n",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: data["subscription_id"]?.toString() ?? "",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text("Actif", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Livraisons",
            subtitle:
            "${data["deliveriesUsed"] ?? '0'}/${data["deliveriesTotal"] ?? '0'}",
            isSvg: false,
            iconBgColor: const Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "Clock.svg",
            title: "Expire Le ",
            subtitle: data["end_date"]?.toString() ?? "********",
            isSvg: true,
            iconColor: const Color(0xFFCD1F45),
            iconBgColor: const Color(0xFFFFC8D4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9EE),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text('Partager votre Abonnement',
                      style: TextStyle(color: KColors.primaryColor)),
                  const SizedBox(height: 25),

                  // --- Copier le code ---
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KColors.primaryColor,
                        side: const BorderSide(color: KColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _copyToClipboard(context, data["codeAbonnement"].toString());
                      },
                      icon: const Icon(Icons.code),
                      label: const Text("Copier le code "),
                    ),
                  ),

                  const SizedBox(height: 5),

                /*
                *   // --- Copier le lien ---
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KColors.primaryColor,
                        side: const BorderSide(color: KColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _copyToClipboard(context, data["codeAbonnement"].toString());
                      },
                      icon: const Icon(Icons.link),
                      label: const Text("Copier le Lien"),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // --- Partager ---
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primaryColor,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: KColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _shareText(data["codeAbonnement"].toString());
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Partager"),
                    ),
                  ),
                * */



                  const SizedBox(height: 5),

                  // --- Code Display ---
                  SizedBox(
                    width: 300,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KColors.primaryColor,
                        foregroundColor: KColors.primaryColor,
                        side: const BorderSide(color: KColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _copyToClipboard(context, data["codeAbonnement"].toString());
                      },
                      label: Text(
                        "Code : ${data["codeAbonnement"].toString()}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ------------------- Inactive Subscription Card -------------------
  Widget _buildInactiveCard() {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 10),
            child: Row(
              children: [
                Image.asset(
                  "assets/images/png/abonnement-icons/Package.png",
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 12),
                Text(
                  "Mon abonnement",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(8)),
                  child: Text("Inactif", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Livraisons",
            subtitle: "0/0",
            isSvg: false,
            iconBgColor: Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Expire Dans",
            subtitle: "*********",
            isSvg: false,
            iconBgColor: Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Code",
            subtitle: "**************",
            isSvg: false,
            iconBgColor: Color(0xFFFFC8D4),
          ),
        ],
      ),
    );
  }

  // ------------------- Helper for Card Rows -------------------
  Widget _buildCardRow({
    String? icon,
    required String title,
    required String subtitle,
    bool isSvg = false,
    bool isIcon = false,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
            color: Color(0xFFF3F3F5), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: iconBgColor ?? Colors.grey,
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isSvg
                    ? SvgPicture.asset(
                    "assets/images/png/abonnement-icons/$icon",
                    fit: BoxFit.contain,
                    color: iconColor)
                    : isIcon
                    ? Icon(Icons.code, color: iconColor)
                    : Image.asset(
                    "assets/images/png/abonnement-icons/$icon",
                    fit: BoxFit.contain),
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, color: Colors.grey)),
                SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ------------------- Build Subscription Plans -------------------
  Widget _buildSubscriptionPlans() {
    if (isLoadingPlans) return CircularProgressIndicator();
    if (subscriptionPlans.isEmpty)
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Aucune formule disponible pour le moment."),
      );

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: subscriptionPlans.map((plan) {
        return SubscriptionCard(
          id_pack: plan["id"] ?? 0,
          title: plan["name"] ?? "N/A",
          price: plan["price"] ?? "0",
          borderColor: Color(int.parse(plan["color"] ?? "0xFF000000")),
          accentColor: Color(int.parse(plan["color"] ?? "0xFF000000")),
          livraisons: plan["deliverylimit"].toString(),
          rayon: plan["radius_km"].toString(),
          min: plan["min_order_amount"] ?? "N/A",
          validite: plan["duration_days"].toString(),
          partageable: plan["is_shareable"] ?? false,
        );
      }).toList(),
    );
  }

  // ------------------- Build Method -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 25),
              Text(
                Utils.capitalize(
                    "${AppLocalizations.of(context)?.translate('subscription')}"),
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text("Choisissez la formule qui vous convient",
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.white, size: 26),
              onPressed: _showAddBottomSheet,
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background/Patternfond.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 55, top: 35, right: 25),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${AppLocalizations.of(context)!.translate('enjoy_text')}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "${AppLocalizations.of(context)!.translate('Delivery_text')} \n",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: "${AppLocalizations.of(context)!.translate('free_del_text')}",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 15),
              if (isLoadingSubscription)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (subscriptionFetchFailed || subscriptionData == null)
                _buildInactiveCard()
              else if (subscriptionData!["status_abonnement"].toString() == "1")
                  _buildActiveCard(subscriptionData!)
                else
                  _buildInactiveCard(),
              SizedBox(height: 20),
              _buildSubscriptionPlans(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fonction réutilisable pour copier du texte
void _copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Copié : $text")),
  );
}

void _shareText(String text) {
  Share.share("Voici mon code Abonnement:" + text, subject: "Voici mon code");
}


