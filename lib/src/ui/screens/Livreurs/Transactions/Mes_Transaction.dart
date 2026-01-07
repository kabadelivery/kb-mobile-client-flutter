import 'package:flutter/material.dart';

// 1. Data Models & Enums
enum TransactionFilter { tous, entrees, sorties }

class TransactionModel {
  final String title;
  final String id;
  final String date;
  final String time;
  final int amount;
  final String status;
  final IconData icon;

  TransactionModel({
    required this.title,
    required this.id,
    required this.date,
    required this.time,
    required this.amount,
    this.status = '',
    required this.icon,
  });
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  TransactionFilter _currentFilter = TransactionFilter.tous;

  // 2. Mock Data based on your images
  final List<TransactionModel> _allTransactions = [
    TransactionModel(
      title: "Montant récupéré",
      id: "LIV-1234",
      date: "13 Nov 2025",
      time: "14:30",
      amount: 8000,
      icon: Icons.currency_franc,
    ),
    TransactionModel(
      title: "Frais de livraison",
      id: "LIV-1233",
      date: "12 Nov 2025",
      time: "10:15",
      amount: -2500,
      icon: Icons.pedal_bike,
    ),
    TransactionModel(
      title: "Retrait sur Portefeuille",
      id: "Mixx by Yas +228 70 63 49 34",
      date: "11 Nov 2025",
      time: "16:30",
      amount: -5000,
      status: "En attente",
      icon: Icons.access_time,
    ),
    TransactionModel(
      title: "Retrait sur portefeuille",
      id: "Mixx by Yas +228 70 63 49 34",
      date: "11 Nov 2025",
      time: "16:30",
      amount: -7000,
      status: "Validé",
      icon: Icons.check_circle_outline,
    ),
  ];

  // 3. Filtering Logic
  List<TransactionModel> get _filteredTransactions {
    if (_currentFilter == TransactionFilter.entrees) {
      return _allTransactions.where((t) => t.amount > 0).toList();
    } else if (_currentFilter == TransactionFilter.sorties) {
      return _allTransactions.where((t) => t.amount < 0).toList();
    }
    return _allTransactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSummarySection(),
            const SizedBox(height: 20),
            _buildFilterBar(),
            const SizedBox(height: 10),
            _buildTransactionList(),
            _buildLegend(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFFD31D44),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
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
              Text(
                "Mes transactions",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text("Historique complète", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _summaryCard("23 500", "Total reçu ce mois", Colors.green, Icons.south_west),
          const SizedBox(width: 15),
          _summaryCard("11 000", "Total retiré ce mois", Colors.red, Icons.north_east),
        ],
      ),
    );
  }

  Widget _summaryCard(String amount, String sub, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 5),
            Text(amount, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _filterButton("Tous", TransactionFilter.tous),
          _filterButton("Entrées", TransactionFilter.entrees),
          _filterButton("Sorties", TransactionFilter.sorties),
        ],
      ),
    );
  }

  Widget _filterButton(String label, TransactionFilter filter) {
    bool isSelected = _currentFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentFilter = filter),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD31D44) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final tx = _filteredTransactions[index];
        return _transactionItem(tx);
      },
    );
  }

  Widget _transactionItem(TransactionModel tx) {
    bool isIncome = tx.amount > 0;
    Color themeColor = isIncome ? Colors.green : Colors.red;
    if (tx.status == "En attente") themeColor = Colors.orange;
    if (tx.status == "Validé") themeColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(tx.icon, color: themeColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("${tx.id}\n${tx.date} • ${tx.time}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (tx.status.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(tx.status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              Text(
                "${isIncome ? '+' : ''}${tx.amount} FCFA",
                style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Légende des transactions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 15),
          _legendItem(Colors.green, "💵 Montant récupéré (livraison)"),
          _legendItem(Colors.red, "🏎️ Frais de livraisons payés"),
          _legendItem(Colors.blue, "🏦 Retrait Mobile Money validé"),
          _legendItem(Colors.orange, "⚠️ Retrait en cours de traitement"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
  }
}