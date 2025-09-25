import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import your other pages here
// import 'NewDesignOrderPage.dart';
class SubscriptionSuccessSheet extends StatefulWidget {
  const SubscriptionSuccessSheet({super.key});

  @override
  State<SubscriptionSuccessSheet> createState() =>
      _SubscriptionSuccessSheetState();

  /// Show the sheet anywhere
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const SubscriptionSuccessSheet(),
    );
  }
}

class _SubscriptionSuccessSheetState extends State<SubscriptionSuccessSheet> {
  late Future<Map<String, dynamic>> _subscriptionData;

  @override
  void initState() {
    super.initState();
    _subscriptionData = fetchSubscriptionData();
  }

  /// Example API fetch function
  Future<Map<String, dynamic>> fetchSubscriptionData() async {
    try {
      final response = await http.get(
        Uri.parse("https://0c137bece99a.ngrok-free.app/dashboard/subscribeduser/39978"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        return {"status_payement": 0};
      }
    } catch (_) {
      return {"status_payement": 0};
    }
  }

@override
Widget build(BuildContext context) {
  return FutureBuilder<Map<String, dynamic>>(
    future: _subscriptionData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError || snapshot.data?['status_payement'] != 1) {
        return Center(
          child: Container(
            width: 300,
            height: 100, // fixed width for error box
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(vertical: 50),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red),
            ),
            child: const Text(
              "Le paiement n'a pas été validé",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }

      // ✅ Payment successful — show the original UI
      return Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ En-tête vert
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Code d'abonnement activé",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Vous avez maintenant accès à un abonnement partagé",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Plan & prix
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.shield, color: Colors.blue),
                title: const Text("Plan BASIC"),
                trailing: const Text(
                  "2500 CFA",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ✅ Période d’activation
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text("Période d’activation"),
                subtitle: const Text("Début: 01/09/2025  •  Fin: 28/09/2025"),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Actions rapides
            const Text("Actions rapides",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share, color: Colors.red),
                  title: const Text("Partager mon abonnement"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.red),
                  title: const Text("Commander un article sur KABA"),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Colors.red),
                  title: const Text("Consulter mon tableau de bord"),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ Prochaines étapes
            const Text("Prochaines étapes",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("• Commandez vos premiers produits"),
                Text("• Invitez vos proches à rejoindre l’abonnement KABA"),
                Text("• Consultez vos statistiques de livraison"),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    )
            ],
          ),
        ),
      );
    },
  );
}

}
