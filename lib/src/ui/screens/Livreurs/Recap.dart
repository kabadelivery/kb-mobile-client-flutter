import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/Besoin_Livreurs/deliveryconfig.dart';

class RecapPage extends StatelessWidget {
  final List<DeliveryConfig> deliveries;

  const RecapPage({super.key, required this.deliveries});

  // --- Constants for Fees ---
  static const double baseFeePerDelivery = 2500.0;
  static const double serviceFee = 200.0;
  static const double additionalFee = 150.0;


  double get totalFees => deliveries.fold(0, (sum, item) => sum + item.deliveryFee);
  double get totalToRecover => deliveries.fold(0, (sum, item) {
    double val = double.tryParse(item.amountToRecover) ?? 0.0;
    return sum + val;
  });


  double get grandTotal => totalFees + serviceFee + additionalFee;

  // --- API SUBMISSION LOGIC ---
  Future<void> _submitData(BuildContext context) async {
    // 1. Configuration & IDs
    final String userId = "36572"; // Replace with your actual user session ID
    final String senderPhone = "+228 90 00 00 00"; // Replace with real user phone
    final String baseUrl = "https://f0404f636233.ngrok-free.app/api/delivery";

    // 2. Show Global Loading Spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD61C4E)),
      ),
    );

    try {
      // --- STEP 1: LOGIC FOR NO RECOVERY (Wallet Check) ---
      if (totalToRecover == 0) {
        // Check if ANY delivery is set to Payment Type 1 (Wallet)
        bool usesWallet = deliveries.any((d) => d.paymentType == 1);

        if (usesWallet) {
          // A. Fetch User Balance
          final balanceRes = await http.get(Uri.parse("$baseUrl/getuserbalance?user_id=$userId"));
          if (balanceRes.statusCode != 200) throw Exception("Impossible de vérifier le solde.");

          final double currentBalance = double.tryParse(jsonDecode(balanceRes.body)['balance'].toString()) ?? 0.0;

          // B. Insufficient Funds Check
          if (currentBalance < grandTotal) {
            Navigator.pop(context); // Close loading
            _showErrorSnackBar(context, "Solde insuffisant (${currentBalance.toInt()} FCFA). Rechargez votre compte.");
            return;
          }

          // C. Process Payment Action
          final payRes = await http.post(
            Uri.parse("$baseUrl/payfordeliveryaction"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"user_id": userId, "amount": grandTotal}),
          );
          if (payRes.statusCode != 200) throw Exception("Échec du paiement via portefeuille.");
        }
      }
      // --- STEP 2: LOGIC FOR RECOVERY (Estimated Deposit) ---
      else if (totalToRecover > grandTotal) {
        double difference = totalToRecover - grandTotal;

        final depositRes = await http.post(
          Uri.parse("$baseUrl/estimeddepositonwallet"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"user_id": userId, "amount": difference}),
        );
        if (depositRes.statusCode != 200) throw Exception("Erreur lors de l'estimation du dépôt.");
      }

      // --- STEP 3: FINAL SUBMISSION OF COMMANDS ---
      List<Map<String, dynamic>> deliveriesPayload = [];
      for (var d in deliveries) {
        // Convert photos to Base64
        List<String?> base64Photos = [];
        for (var file in d.photos) {
          if (file != null) {
            final bytes = await file.readAsBytes();
            base64Photos.add(base64Encode(bytes));
          }
        }

        deliveriesPayload.add({
          "start_address": d.startAddress,
          "destination_address": d.useGps ? "GPS" : d.destinationAddress,
          "dest_latitude": d.destLatitude,
          "dest_longitude": d.destLongitude,
          "receiver_phone": d.phoneNumber,
          "address_details": d.addressDetails,
          "package_nature": d.packageNature,
          "is_scheduled": d.isScheduled,
          "scheduled_date": d.scheduledDate,
          "scheduled_time": d.scheduledTime,
          "is_shop": d.isShop,
          "delivery_fee": d.deliveryFee,
          "recover_amount": d.recoverAmount,
          "amount_to_recover": d.amountToRecover,
          "payment_type": d.paymentType,
          "photos": base64Photos,
        });
      }

      final finalResponse = await http.post(
        Uri.parse("$baseUrl/submit"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "sender_phone": senderPhone,
          "summary": {
            "grand_total": grandTotal,
            "total_recovery": totalToRecover,
          },
          "deliveries": deliveriesPayload,
        }),
      );

      // --- STEP 4: UI FEEDBACK ---
      Navigator.pop(context); // Close loading

      if (finalResponse.statusCode == 200 || finalResponse.statusCode == 201) {
        _showSuccessDialog(context);
      } else {
        throw Exception("Erreur lors de la création de la commande: ${finalResponse.body}");
      }

    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context); // Close loading if open
      _showErrorSnackBar(context, "Erreur: $e");
    }
  }

// Helper to show error messages
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

// Helper for Success Dialog
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Succès"),
        content: const Text("Vos livraisons ont été enregistrées avec succès."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Go back to Home/Previous
            },
            child: const Text("OK", style: TextStyle(color: Color(0xFFD61C4E))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSummaryCard(deliveries.length, totalFees, totalToRecover),
                  const SizedBox(height: 24),
                  const Text(
                    "Détails des livraisons",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...deliveries.asMap().entries.map((entry) {
                    return _buildDeliveryDetailCard(entry.key, entry.value);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomActions(context, grandTotal),
        ],
      ),
    );
  }

  // --- HEADER remains the same ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Récapitulatif",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                ],
              ),
              Text("Vérifiez les détails avant de confirmer",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count, double fees, double recovery) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE52D5E), Color(0xFFC2185B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text("$count livraison${count > 1 ? 's' : ''}",
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          _summaryRow("Total Frais de livraison", "${fees.toInt()} FCFA"),
          const SizedBox(height: 9),
          _summaryRow("Total Montant à récupérer", "${recovery.toInt()} FCFA"),
          const SizedBox(height: 9),
          _summaryRow("Frais de Service", "${serviceFee.toInt()} FCFA"),
          const SizedBox(height: 9),
          _summaryRow("Frais Supplémentaires", "${additionalFee.toInt()} FCFA"),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildDeliveryDetailCard(int index, DeliveryConfig d) {
    // Requirement 2: Logic for "Destinataire" vs "Vous"
    final String payerLabel = (d.paymentType == 1 || d.paymentType == 2) ? "Vous" : "Destinataire";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD61C4E),
                radius: 14,
                child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 12),
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Livraison", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${d.deliveryFee.toInt()} FCFA", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: Color(0xFFD61C4E), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _timelineRow(const Color(0xFF2E7DFF), "Départ", d.startAddress),
                Padding(
                  padding: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(width: 1, height: 20, color: Colors.grey.shade300),
                  ),
                ),
                _timelineRow(
                    const Color(0xFF4CAF50),
                    "Arrivée",
                    // Show the address if it's not empty, regardless of GPS/Quartier mode
                    d.destinationAddress.isNotEmpty
                        ? d.destinationAddress
                        : (d.useGps ? "Position GPS non définie" : "Quartier non défini")
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Frais supportés par", style: TextStyle(fontSize: 13, color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7DFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(payerLabel, // Dynamic based on paymentType
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Driver snippet (keeping as is)
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ama'),
              ),
              const SizedBox(width: 10),
              const Text("Livreur Ama S.", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEFC4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 12),
                    SizedBox(width: 2),
                    Text("4.9", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _timelineRow(Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total à payer :", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                Text("${total.toInt()} FCFA",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD61C4E))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Modifier", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD61C4E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => _submitData(context), // Trigger API Call
                    child: const Text("Confirmer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}