import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:KABA/src/ui/customwidgets/abonnememts/SuscriptionCard.dart';

class SubscriptionPlansSheet extends StatefulWidget {
  const SubscriptionPlansSheet({super.key});

  @override
  State<SubscriptionPlansSheet> createState() => _SubscriptionPlansSheetState();
}

class _SubscriptionPlansSheetState extends State<SubscriptionPlansSheet> {
  List<Map<String, dynamic>> subscriptionPlans = [];
  bool isLoadingPlans = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlans();
  }

  /// ------------------- Fetch Available Plans -------------------
  Future<void> _fetchSubscriptionPlans() async {
    final url = Uri.parse("https://c7d355e6cbf7.ngrok-free.app/dashboard/packs");
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
      if (!mounted) return;
      setState(() {
        subscriptionPlans = [];
        isLoadingPlans = false;
      });
    }
  }

  /// ------------------- Build Subscription Plans -------------------
  Widget _buildSubscriptionPlans() {
     if (isLoadingPlans) return CircularProgressIndicator();
    if (subscriptionPlans.isEmpty) return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text("Aucune formule disponible pour le moment."),
    );

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
          livraisons: plan["deliverylimit"].toString(),
          rayon: plan["radius_km"].toString(),
          min: plan["min_order_amount"] ?? "N/A",
          validite: plan["duration_days"].toString(),
          partageable: plan["is_shareable"] ?? false,
        ); 
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.drag_handle, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            const Text(
              "Formules d’abonnement",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSubscriptionPlans(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
