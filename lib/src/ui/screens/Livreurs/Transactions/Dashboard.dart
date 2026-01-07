import 'package:flutter/material.dart';

import 'Mes_Transaction.dart';

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Red Gradient Background
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFFF8A65)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildBalanceSection(),
                  _buildActionButtons(context),
                  _buildTransactionList(),
                  _buildMonthlyStats(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header with Back button and Wallet Icon ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back, color: Colors.white),
          Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
        ],
      ),
    );
  }

  // --- Balance Display ---
  Widget _buildBalanceSection() {
    return Column(
      children: [
        Text("Solde disponible", style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text("12 500", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text("FCFA", style: TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
        const SizedBox(height: 15),
        // Waiting Withdrawal Pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text("Retrait en attente : 5 000 FCFA", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  // --- Withdrawal and Transactions Buttons ---
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _actionCard(
            "Faire un retrait",
            Icons.file_download_outlined,
            const Color(0xFFFCE4EC),
            const Color(0xFFC2185B),
                () => _showWithdrawalModal(context), // Logic for Image 3
          ),
          const SizedBox(width: 15),
          _actionCard(
            "Mes transactions",
            Icons.visibility_outlined,
            const Color(0xFFFCE4EC),
            const Color(0xFFC2185B),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsPage())), // Logic for Image 2
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell( // Added for clickability
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Recent Transactions ---
  Widget _buildTransactionList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Transactions récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Tout voir", style: TextStyle(color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 15),
          _transactionItem("Montant récupéré", "13 Nov 2025 • 14:30", "+8 000", Colors.green),
          _transactionItem("Frais de livraison", "12 Nov 2025 • 10:15", "- 2 500", Colors.red),
          _transactionItem("Retrait sur Portefeuille", "11 Nov 2025 • 16:30", "-7 000", Colors.red),
        ],
      ),
    );
  }

  Widget _transactionItem(String title, String subtitle, String amount, Color amountColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: amountColor == Colors.green ? Color(0xFFE8F5E9) : Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(amountColor == Colors.green ? Icons.currency_franc : Icons.directions_bike, color: amountColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text("$amount FCFA", style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Bottom Summary Stats ---
  Widget _buildMonthlyStats() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _statCard("23 500", "Total reçu ce mois", Colors.green, Color(0xFFE8F5E9)),
          const SizedBox(width: 15),
          _statCard("11 000", "Total retiré ce mois", Colors.red, Color(0xFFFFF1F0)),
        ],
      ),
    );
  }

  Widget _statCard(String amount, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(color == Colors.green ? Icons.south_west : Icons.north_east, color: color),
            const SizedBox(height: 10),
            Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

void _showWithdrawalModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
      ),
      padding: const EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    children: [
                      TextSpan(text: "Retrait ", style: TextStyle(color: Color(0xFFC2185B))),
                      TextSpan(text: "sur Portefeuille"),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputLabel("Montant à retirer (FCFA)"),
            TextField(decoration: InputDecoration(hintText: "Ex : 10 000", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["5 000", "10 000", "15 000"].map((val) => _quickAmountChip(val)).toList(),
            ),
            const SizedBox(height: 25),
            _buildInputLabel("Opérateur Mobile Money"),
            _operatorTile("Mixx by Yas", "assets/mixx_logo.png", true),
            _operatorTile("Moov Money", "assets/moov_logo.png", false),
            const SizedBox(height: 25),
            _buildInputLabel("Numéro de dépôt"),
            TextField(decoration: InputDecoration(hintText: "+228 XX XX XX XX", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC2185B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {},
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.check_circle_outline, color: Colors.white), SizedBox(width: 10), Text("Confirmer le retrait", style: TextStyle(color: Colors.white, fontSize: 16))],
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

// Helper for modal labels
Widget _buildInputLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
       // Icon(ic, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
      ],
    ),
  );
}

// Helper for amount chips
Widget _quickAmountChip(String amount) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
    child: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

// Helper for operator selection
Widget _operatorTile(String name, String imgPath, bool isSelected) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFFFCE4EC) : Colors.grey[50],
      border: Border.all(color: isSelected ? const Color(0xFFC2185B) : Colors.grey[200]!),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Row(
      children: [
        Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFFC2185B)),
        const SizedBox(width: 15),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

