import 'package:flutter/material.dart';

class SubscriptionSuccessSheet extends StatelessWidget {
  const SubscriptionSuccessSheet({super.key});

  /// Use this anywhere in your app to show the sheet
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
            // ✅ Green success header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 48),
                  SizedBox(height: 10),
                  Text(
                    "Code d'abonnement activé",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Vous avez maintenant accès à un abonnement partagé",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Plan & price
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.shield, color: Colors.blue),
                title: Text("Plan BASIC"),
                trailing: Text(
                  "2500 CFA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Activation period
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ListTile(
                leading: Icon(Icons.calendar_today, color: Colors.blue),
                title: Text("Période d’activation"),
                subtitle: Text("Début: 01/09/2025  •  Fin: 28/09/2025"),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Quick actions
            const Text(
              "Actions rapides",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.red),
              title: const Text("Partager mon abonnement"),
              onTap: () {
                // TODO: Add sharing logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.red),
              title: const Text("Commander un article sur KABA"),
              onTap: () {
                // TODO: Navigate to orders
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.red),
              title: const Text("Consulter mon tableau de bord"),
              onTap: () {
                // TODO: Navigate to dashboard
              },
            ),
            const SizedBox(height: 16),

            // ✅ Next steps
            const Text(
              "Prochaines étapes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("• Commandez vos premiers produits"),
            const Text("• Invitez vos proches à rejoindre l’abonnement KABA"),
            const Text("• Consultez vos statistiques de livraison"),
            const SizedBox(height: 24),

            // ✅ Button to close
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.done, color: Colors.white),
                label: const Text(
                  "Fermer",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
