import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CommingLivreurs.dart';

class LiveTrackingPage extends StatefulWidget {
  const LiveTrackingPage({super.key});

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  List<LiveDelivery> deliveries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserCommands();
  }

  // --- API CALL ---
  Future<void> fetchUserCommands() async {
    const String userId = "36572"; // Replace with your dynamic user session ID
    final String url = "https://953fd32c7748.ngrok-free.app/api/delivery/getcommands?user_id=$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          deliveries = jsonData.map((item) {
            // Map the PHP statuscommand to your Flutter Enum
            DeliveryStatus status;
            int statusInt = item['status'];
            bool canTrack = false;

            switch (statusInt) {
              case 0: status = DeliveryStatus.processing; break;
              case 1: status = DeliveryStatus.accepted; break;
              case 2: status = DeliveryStatus.onTheWay; canTrack = true; break;
              case 3: status = DeliveryStatus.delivering; canTrack = true; break;
              case 4: status = DeliveryStatus.delivered; break;
              case -1: status = DeliveryStatus.failed; break;
              default: status = DeliveryStatus.processing;
            }

            return LiveDelivery(
              status: status,
              departure: item['depart'] ?? "N/A",
              arrival: item['arrivee'] ?? "N/A",
              courierName: item['driver'] ?? "Non assigné",
              rating: 4.9, // Default since not in current entity
              deliveryFee: int.tryParse(item['fees'].toString().replaceAll(' ', '')) ?? 0,
              amountToRecover: int.tryParse(item['recovery'].toString().replaceAll(' ', '')) ?? 0,
              canTrack: canTrack,
              timeAgo: "Il y a 5 min", // You can map item['date'] here if needed
            );
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() { isLoading = false; });
      debugPrint("Error fetching commands: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _header(deliveries.length),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFD61C4E)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (_, i) => _deliveryCard(context, deliveries[i]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD61C4E),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => fetchUserCommands(), // Refresh button
              child: const Text("Voir tout", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_back, color: Colors.white),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Suivi en direct", style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("$count livraisons actives", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.phone, color: Colors.white),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _deliveryCard(BuildContext context, LiveDelivery d) {
    final style = _statusStyle(d.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: style.color, borderRadius: BorderRadius.circular(20)),
                child: Text(style.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const Spacer(),
              Text(d.timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _location("Départ", d.departure, Colors.blue),
          _location("Arrivée", d.arrival, Colors.green),
          if (d.canTrack)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: style.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DeliveryTrackingPage()));
                  },
                  child: const Text("Suivre en direct", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
              const SizedBox(width: 8),
              Text("Livreur ${d.courierName}"),
              const SizedBox(width: 6),
              _rating(d.rating),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Frais : ${d.deliveryFee}F | À récup : ${d.amountToRecover}F",
              style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ================= HELPERS (SAME AS YOURS) =================
  Widget _location(String label, String value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rating(double r) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(6)),
    child: Row(children: [const Icon(Icons.star, size: 12, color: Colors.orange), Text("$r", style: const TextStyle(fontSize: 12))]),
  );

  _StatusStyle _statusStyle(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.processing: return _StatusStyle("Traitement en cours", Colors.grey);
      case DeliveryStatus.accepted: return _StatusStyle("Demande acceptée", Colors.teal);
      case DeliveryStatus.onTheWay: return _StatusStyle("Livreur en route", Colors.blue);
      case DeliveryStatus.delivering: return _StatusStyle("Colis en cours de livraison", Colors.orange);
      case DeliveryStatus.delivered: return _StatusStyle("Livré", Colors.green);
      case DeliveryStatus.failed: return _StatusStyle("Échec", Colors.red);
    }
  }
}

// ================= DATA CLASSES =================
class _StatusStyle {
  final String label;
  final Color color;
  _StatusStyle(this.label, this.color);
}

enum DeliveryStatus { processing, accepted, onTheWay, delivering, delivered, failed }

class LiveDelivery {
  final DeliveryStatus status;
  final String departure;
  final String arrival;
  final String courierName;
  final double rating;
  final int deliveryFee;
  final int amountToRecover;
  final bool canTrack;
  final String timeAgo;

  LiveDelivery({
    required this.status, required this.departure, required this.arrival,
    required this.courierName, required this.rating, required this.deliveryFee,
    required this.amountToRecover, this.canTrack = false, required this.timeAgo
  });
}