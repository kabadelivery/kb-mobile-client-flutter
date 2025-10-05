import 'dart:convert';
import 'package:KABA/src/contracts/transaction_contract.dart';

import 'package:KABA/src/ui/customwidgets/abonnememts/SuscriptionCard.dart';
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
  }

  // Initialize data: load customer first, then fetch subscription & plans
  Future<void> _initData() async {
    await _loadCustomer();
    await _fetchSubscription();
    await _fetchSubscriptionPlans();
  }

  // Load customer and store ID
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

    final url =
        Uri.parse(ServerRoutes.KABA_ABONNEMENT_SUSCRIBED_USER + "/$customerId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;

        setState(() {
          subscriptionData = data;
          isLoadingSubscription = false;
        });
      } else {
        throw Exception(
            "Failed to fetch subscription for customer $customerId");
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

  // ------------------- Active Subscription Card -------------------
  Widget _buildActiveCard(Map<String, dynamic> data) {
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
                RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: "Mon abonnement\n",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: data["subscription_id"],
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    ],
  ),
),
                Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text("Actif", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
          _buildCardRow(
            icon: "Package.png",
            title: "Livraisons",
            subtitle:
                "${data["deliveriesUsed"] ?? 0}/${data["deliveriesTotal"] ?? 0}",
            isSvg: false,
            iconBgColor: Color(0xFFFFC8D4),
          ),
          _buildCardRow(
            icon: "Clock.svg",
            title: "Expire Le ",
            subtitle: data["end_date"] ?? "********",
            isSvg: true,
            iconColor: Color(0xFFCD1F45),
            iconBgColor: Color(0xFFFFC8D4),
          ),
          /* _buildCardRow(
            icon: "code",
            title: "Code",
            subtitle: data["codeAbonnement"] ?? "********",
            isIcon: true,
            iconColor: Color(0xFFCD1F45),
            iconBgColor: Color(0xFFFFC8D4),
          ), */
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0), // internal padding
                decoration: BoxDecoration(
                  color: Color(0xFFFFE9EE), // grey background
                  borderRadius: BorderRadius.circular(8), // small border radius
                ),
                height: 300 , // fixed width
                child: Column(children: [
                  SizedBox(height: 5),
                  Text('Partager votre Abonnement',style: TextStyle(color: KColors.primaryColor),),
                  SizedBox(height: 25),
                  SizedBox(
                    width: 300, // set your desired width here
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
                        _copyToClipboard(context, data["codeAbonnement"]);
                      },
                      icon: const Icon(Icons.code),
                      label: const Text("Copier le code "),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 300, // set your desired width here
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
                        // CopyButton( textToCopy: data["codeAbonnement"]);
                        _copyToClipboard(context,
                            data["codeAbonnement"]); // <-- ta fonction ici
                      },
                      icon: const Icon(Icons.link),
                      label: const Text("Copier le Lien"),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 300, // set your desired width here
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
                        _shareText(data[
                            "codeAbonnement"]); // <-- appelle la fonction partager
                      },
                      icon: const Icon(Icons.share),
                      label: const Text("Partager"),
                    ),
                  ),
                  SizedBox(height: 5),
                   SizedBox(
                    width: 300, // set your desired width here
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
                        // CopyButton( textToCopy: data["codeAbonnement"]);
                        _copyToClipboard(context,
                            data["codeAbonnement"]); // <-- ta fonction ici
                      },
                      
                      label: Text("Code :" + data["codeAbonnement"],style: TextStyle(color: Colors.black),),
                    ),
                  ),
                  /* SizedBox(
                    width: 300, // set your desired width here
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {},
                      label: Text("Code :" + data["codeAbonnement"]),
                    ),
                  ), */
                ])),
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
                  "Mon abonnement"+customerId.toString(),
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
                    "${AppLocalizations.of(context)?.translate('T_suscription')}"),
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text("Choisissez la formule qui vous convient",
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
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

              Center(child: Padding(
                    padding: const EdgeInsets.only(
                        left: 55, top: 35, right: 25), // top spacing
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center, // center the text
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Profitez des ", // line break before "Gratuite"
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "livraisons \n", // line break before "Gratuite"
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: "GRATUITES", // "Gratuite" in red
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor, // red color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 15),
              // ----------------- Current Subscription -----------------
              if (isLoadingSubscription)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (subscriptionFetchFailed || subscriptionData == null)
                _buildInactiveCard()
              else if (subscriptionData!["status_abonnement"] == 1)
                _buildActiveCard(subscriptionData!)
              else
                _buildInactiveCard(),

              SizedBox(height: 20),
              // ----------------- Subscription Plans -----------------
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
