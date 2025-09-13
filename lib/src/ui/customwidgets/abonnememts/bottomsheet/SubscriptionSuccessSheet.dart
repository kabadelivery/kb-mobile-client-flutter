import 'package:flutter/material.dart';
// import your other pages here
// import 'NewDesignOrderPage.dart';

class SubscriptionSuccessSheet extends StatefulWidget {
  const SubscriptionSuccessSheet({super.key}); 
  
  @override
  State<SubscriptionSuccessSheet> createState() =>
      _SubscriptionSuccessSheetState();

  /// ✅ Use this helper to show the sheet anywhere
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Success header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Paiement réussi !\nVotre abonnement est maintenant actif !",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 📦 Plan info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.shield, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Plan BASIC",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text("2500 CFA",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("Payé via Portefeuille KABA",
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 📅 Activation period
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE1EDFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Période d’activation",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Début: 01/05/2025"),
                      Text("Fin: 25/05/2025"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ⚡ Quick actions
            const Text("Actions rapides",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Button 1
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFCD1F45),
                          side: const BorderSide(color: Color(0xFFCD1F45)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Partager mon Abonnement"),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔹 Button 2
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFCD1F45),
                          side: const BorderSide(color: Color(0xFFCD1F45)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Placeholder(), // Replace with NewDesignOrderPage()
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Commander un article sur Kaba"),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔹 Button 3
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFCD1F45),
                          side: const BorderSide(color: Color(0xFFCD1F45)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          // TODO: navigate to dashboard
                        },
                        icon: const Icon(Icons.file_copy),
                        label: const Text("Consulter le Tableau de bord"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 📌 Next steps
            const Text("Prochaines étapes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("• Commandez vos premiers produits"),
            const Text("• Invitez vos proches à rejoindre l’abonnement"),
            const Text("• Consultez vos statistiques de livraison"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
