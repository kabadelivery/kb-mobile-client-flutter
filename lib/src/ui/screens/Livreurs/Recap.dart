import 'package:flutter/material.dart';
import 'dart:io';
// Ensure this matches your project structure
import '../../../models/Besoin_Livreurs/deliveryconfig.dart';

class RecapPage extends StatelessWidget {
  final List<DeliveryConfig> deliveries;

  const RecapPage({super.key, required this.deliveries});

  @override
  Widget build(BuildContext context) {
    // Logic to calculate totals for the red summary card
    double totalFees = deliveries.fold(0, (sum, item) => sum + 2500.0); // Assuming 2500 per delivery
    double totalToRecover = deliveries.fold(0, (sum, item) {
      double val = double.tryParse(item.amountToRecover) ?? 0.0;
      return sum + val;
    });

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
                  // List of delivery details
                  ...deliveries.asMap().entries.map((entry) {
                    return _buildDeliveryDetailCard(entry.key, entry.value);
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomActions(totalFees),
        ],
      ),
    );
  }

  // --- HEADER ---
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

  // --- TOP RED SUMMARY CARD ---
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
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          _summaryRow("Total Frais de livraison", "${fees.toInt()} FCFA"),
          const SizedBox(height: 12),
          _summaryRow("Total Montant à récupérer", "${recovery.toInt()} FCFA"),
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

  // --- INDIVIDUAL DELIVERY DETAIL CARD ---
  Widget _buildDeliveryDetailCard(int index, DeliveryConfig d) {
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
                  Text("Livraison ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text("2500 FCFA", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined, color: Color(0xFFD61C4E), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          // Vertical Timeline for Addresses
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
                _timelineRow(const Color(0xFF4CAF50), "Arrivée",
             d.useGps ? "Position GPS sélectionnée" : (d.destinationAddress.isNotEmpty ? d.destinationAddress : "Quartier non défini"))
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Support Fee Toggle Style
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
                  child: const Text("Destinataire", // Hardcoded based on image
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Driver Info Snippet
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ama'), // Example image
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

  // --- BOTTOM ACTIONS ---
  Widget _buildBottomActions(double total) {
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
                    onPressed: () {},
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
                    onPressed: () {},
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