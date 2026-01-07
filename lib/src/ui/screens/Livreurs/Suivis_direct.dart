import 'package:flutter/material.dart';

import 'CommingLivreurs.dart';

class LiveTrackingPage extends StatelessWidget {
  LiveTrackingPage({super.key});

  final List<LiveDelivery> deliveries = [
    LiveDelivery(
      status: DeliveryStatus.processing,
      departure: "Tokoin, Lomé",
      arrival: "Agoè, Lomé",
      courierName: "Koffi M.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
    ),
    LiveDelivery(
      status: DeliveryStatus.accepted,
      departure: "Nyékonakpoè, Lomé",
      arrival: "Hédzranawoè, Lomé",
      courierName: "Ama S.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
    ),
    LiveDelivery(
      status: DeliveryStatus.onTheWay,
      departure: "Nyékonakpoè, Lomé",
      arrival: "Hédzranawoè, Lomé",
      courierName: "Ama S.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
      canTrack: true,
    ),
    LiveDelivery(
      status: DeliveryStatus.delivering,
      departure: "Nyékonakpoè, Lomé",
      arrival: "Hédzranawoè, Lomé",
      courierName: "Ama S.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
      canTrack: true,
    ),
    LiveDelivery(
      status: DeliveryStatus.delivered,
      departure: "Bè, Lomé",
      arrival: "Adidogomé, Lomé",
      courierName: "Ama S.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
    ),
    LiveDelivery(
      status: DeliveryStatus.failed,
      departure: "Bè, Lomé",
      arrival: "Adidogomé, Lomé",
      courierName: "Ama S.",
      rating: 4.9,
      deliveryFee: 3500,
      amountToRecover: 3000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _header(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (_, i) => _deliveryCard(context, deliveries[i]),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {},
              child: const Text("Voir tout"),
            ),
          )
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFD61C4E), Color(0xFFB01C3A)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: const [
          Icon(Icons.arrow_back, color: Colors.white),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Suivi en direct",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Text("3 livraisons actives",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          Spacer(),
          Icon(Icons.phone, color: Colors.white),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // STATUS
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(style.label,
                    style: const TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              const Text("Il y a 5 min",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeliveryTrackingPage()),
                    );
                  },
                  child: const Text("Suivre en direct"),
                ),
              ),
            ),

          const Divider(height: 24),

          Row(
            children: [
              const CircleAvatar(radius: 18),
              const SizedBox(width: 8),
              Text("Livreur ${d.courierName}"),
              const SizedBox(width: 6),
              _rating(d.rating),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Frais de livraison : ${d.deliveryFee}F | Montant à récup : ${d.amountToRecover}F",
              style: const TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  // ================= HELPERS =================
  Widget _location(String label, String value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration:
            BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rating(double r) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.orange.shade100,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        const Icon(Icons.star, size: 12, color: Colors.orange),
        Text("$r", style: const TextStyle(fontSize: 12)),
      ],
    ),
  );

  _StatusStyle _statusStyle(DeliveryStatus s) {
    switch (s) {
      case DeliveryStatus.processing:
        return _StatusStyle("Traitement en cours", Colors.grey);
      case DeliveryStatus.accepted:
        return _StatusStyle("Demande acceptée", Colors.teal);
      case DeliveryStatus.onTheWay:
        return _StatusStyle("Livreur en route", Colors.blue);
      case DeliveryStatus.delivering:
        return _StatusStyle("Colis en cours de livraison", Colors.orange);
      case DeliveryStatus.delivered:
        return _StatusStyle("Livré", Colors.green);
      case DeliveryStatus.failed:
        return _StatusStyle("Échec", Colors.red);
    }
  }
}

class _StatusStyle {
  final String label;
  final Color color;

  _StatusStyle(this.label, this.color);
}

enum DeliveryStatus {
  processing,
  accepted,
  onTheWay,
  delivering,
  delivered,
  failed,
}

class LiveDelivery {
  final DeliveryStatus status;
  final String departure;
  final String arrival;
  final String courierName;
  final double rating;
  final int deliveryFee;
  final int amountToRecover;
  final bool canTrack;

  LiveDelivery({
    required this.status,
    required this.departure,
    required this.arrival,
    required this.courierName,
    required this.rating,
    required this.deliveryFee,
    required this.amountToRecover,
    this.canTrack = false,
  });
}

