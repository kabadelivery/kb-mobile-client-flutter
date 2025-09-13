import 'dart:convert';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SuscriptionCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:KABA/src/models/CustomerModel.dart';

import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';

class Kaba_abonnement extends StatefulWidget {
  static var routeName = "/Kaba_abonnement";
  final CustomerModel? customer;

  const Kaba_abonnement({Key? key, this.customer, required TransactionPresenter presenter}) : super(key: key);

  @override
  _Kaba_abonnementState createState() => _Kaba_abonnementState();
}

class _Kaba_abonnementState extends State<Kaba_abonnement> {
  Map<String, dynamic>? subscriptionData;
  bool isLoadingSubscription = true;
  bool subscriptionFetchFailed = false;

  List<Map<String, dynamic>> subscriptionPlans = [];
  bool isLoadingPlans = true;

    int? customerId; // ✅ on déclare l’id ici

  @override
  void initState() {
    super.initState();


    customerId = widget.customer?.id;
    _fetchSubscription();
    _fetchSubscriptionPlans();

    // Fallback: after 5 seconds, mark subscription as Inactif
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && isLoadingSubscription) {
        setState(() {
          subscriptionData = {"status": "Inactif"};
          isLoadingSubscription = false;
          subscriptionFetchFailed = false;
        });
      }
    });
  }

// ------------------- Fetch Current Subscription -------------------
Future<void> _fetchSubscription() async {

 // final customerId = widget.customer?.id; // 👈 get customer id
   final customerId = "1958"; // 👈 get customer id

  if (customerId == null) {
    print("⚠️ No customer ID provided.");
    setState(() {
      subscriptionData = {"status": "Inactif"}; // fallback
      isLoadingSubscription = false;
    });
    return;
  }

  // 👇 Adjust your API endpoint to accept the customerId
  final url = Uri.parse("https://example.com/api/subscription/$customerId");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (!mounted) return;
      setState(() {
        subscriptionData = json.decode(response.body);
        isLoadingSubscription = false;
      });
    } else {
      throw Exception("Failed to fetch subscription for customer $customerId");
    }
  } catch (e) {
    print("❌ Error fetching subscription for $customerId: $e");
    if (!mounted) return;
    setState(() {
      subscriptionData = {"status": "Inactif"}; // fallback
      subscriptionFetchFailed = true;
      isLoadingSubscription = false;
    });
  }
}


  // ------------------- Fetch Available Plans -------------------
  Future<void> _fetchSubscriptionPlans() async {
    final url = Uri.parse("https://4bd2bdf8b447.ngrok-free.app/dashboard/packs");
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
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "Actif",
                    style: TextStyle(color: Colors.white),
                  ),
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
              iconBgColor: Color(0xFFFFC8D4)),
          _buildCardRow(
              icon: "Clock.svg",
              title: "Expire dans",
              subtitle: data["expiryDate"] ?? "********",
              isSvg: true,
              iconColor: Color(0xFFCD1F45),
              iconBgColor: Color(0xFFFFC8D4)),
          _buildCardRow(
              icon: "code",
              title: "Code",
              subtitle: data["code"] ?? "********",
              isIcon: true,
              iconColor: Color(0xFFCD1F45),
              iconBgColor: Color(0xFFFFC8D4)),
        ],
      ),
    );
  }

  // ------------------- Inactive Subscription Card -------------------
  Widget _buildInactiveCard(Map<String, dynamic> data) {
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
                  "Mon abonnement"+ customerId.toString(),
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
                  child: Text(
                    "Inactif",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child: Image.asset(
      "assets/images/png/abonnement-icons/Package.png", // your image
      fit: BoxFit.contain,
    ),
  ),
 ), SizedBox(width: 15,) , Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Livraisons",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "0/0",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child:  SvgPicture.asset(
      "assets/images/png/abonnement-icons/Clock.svg", // your SVG file
      fit: BoxFit.contain,
      color: Color(0xFFCD1F45), // optional: change stroke color
    ),
  ),
 ), SizedBox(width: 15,) , Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Expire dans",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "********",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // internal padding
    decoration: BoxDecoration(
      color: Color(0xFFF3F3F5), // grey background
      borderRadius: BorderRadius.circular(8), // small border radius
    ),
    child: Row(
      children: [
       Container(
  width: 40, // small square container
  height: 40,
  decoration: BoxDecoration(
    color: Color(0xFFFFC8D4), // background color
    borderRadius: BorderRadius.circular(8), // rounded corners
  ),
  child: Padding(
    padding: const EdgeInsets.all(8.0), // inner padding for the image
    child: Icon(  Icons.code, color: Color(0xFFCD1F45)),
 ), ),
 SizedBox(width: 15) ,
  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Code",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4), // spacing between texts
          Text(
            "*********",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),  
      ],
    ),
  ),
),

Padding(padding: EdgeInsets.only(top: 20, bottom: 20 , left: 25.0, right: 16.0),
        child: Text(
          "Choisissez une formule ci-dessous pour commencer !",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ),


        ],
      ),
    );
  }

  // ------------------- Helper for Card Rows -------------------
  Widget _buildCardRow(
      {String? icon,
      required String title,
      required String subtitle,
      bool isSvg = false,
      bool isIcon = false,
      Color? iconColor,
      Color? iconBgColor}) {
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
                        color: iconColor,
                      )
                    : isIcon
                        ? Icon(Icons.code, color: iconColor)
                        : Image.asset(
                            "assets/images/png/abonnement-icons/$icon",
                            fit: BoxFit.contain,
                          ),
              ),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 15, color: Colors.grey)),
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

    if (subscriptionPlans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Aucune formule disponible pour le moment."),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: subscriptionPlans.map((plan) {
        return
        
      

          SubscriptionCard(
          id_pack: plan["id"] ?? 0,
          title: plan["name"] ?? "N/A",
          price: plan["price"] ?? "0",
          borderColor: Color(int.parse(plan["color"] ?? "0xFF000000")),
          accentColor: Color(int.parse(plan["color"] ?? "0xFF000000")), 
          livraisons: plan["deliverylimit"].toString() ?? "N/A",
          rayon: plan["radius_km"].toString() ?? "N/A",
          min: plan["min_order_amount"] ?? "N/A",
          validite: plan["duration_days"].toString() ?? "N/A", 
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
              Text(
                "Choisissez la formule qui vous convient",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
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

                Padding(
  padding: const EdgeInsets.only(left: 55 , top: 35 , right: 25 ), // top spacing
  child: Center(
    child: RichText(
      textAlign: TextAlign.center, // center the text
      text: TextSpan(
        children: [
          TextSpan(
            text: "Profitez des ", // line break before "Gratuite"
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
           TextSpan(
            text: "livraisons \n", // line break before "Gratuite"
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
)
,
              // ----------------- Current Subscription -----------------
              if (isLoadingSubscription)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )
              else if (subscriptionFetchFailed &&
                  subscriptionData?["status"] != "Inactif")
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Impossible de récupérer votre abonnement.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              else if (subscriptionData?["status"] == "Actif")
                _buildActiveCard(subscriptionData!)
              else
                _buildInactiveCard(subscriptionData!),

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
