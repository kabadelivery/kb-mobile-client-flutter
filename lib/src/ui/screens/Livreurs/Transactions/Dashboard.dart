import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../customwidgets/BesoinLivreurs/ConfirmationModal.dart';
import '../../../customwidgets/BesoinLivreurs/InformationModal.dart';
import 'Mes_Transaction.dart';


class WalletPage extends StatefulWidget {
  final int userId;

  const WalletPage({Key? key, required this.userId}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // State variables
  String balance = "0";
  bool isLoading = true;
  List transactions = [];

  // Controllers for the Withdrawal Modal
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedOperator = "Mixx by Yas";

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    final String baseUrl = "https://953fd32c7748.ngrok-free.app/api/delivery";
    try {
      final balanceRes = await http.get(Uri.parse("$baseUrl/getuserbalance?user_id=${widget.userId}"));
      // Note: We'll creat00e this gettransactions endpoint in Symfony next
      final transRes = await http.get(Uri.parse("$baseUrl/gettransactions?user_id=${widget.userId}"));

      if (mounted) {
        setState(() {
          balance = json.decode(balanceRes.body)['balance'].toString();
          transactions = json.decode(transRes.body);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : RefreshIndicator(
              onRefresh: _fetchWalletData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildBalanceSection(balance),
                    _buildActionButtons(context),
                    _buildTransactionList(transactions),
                    _buildMonthlyStats(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
            onPressed: () => InformationModal.show(context),
          ),

        ],
      ),
    );
  }

  Widget _buildBalanceSection(String amount) {
    return Column(
      children: [
        const Text("Solde disponible", style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Text("FCFA", style: TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
        const SizedBox(height: 15),
        _buildWaitingPill(),
      ],
    );
  }

  Widget _buildWaitingPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text("Retrait en attente : 0 FCFA", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _actionCard("Faire un retrait", Icons.file_download_outlined, const Color(0xFFFCE4EC), const Color(0xFFC2185B),
                  () => _showWithdrawalModal(context)),
          const SizedBox(width: 15),
          _actionCard("Mes transactions", Icons.visibility_outlined, const Color(0xFFFCE4EC), const Color(0xFFC2185B),
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionsPage()))),
        ],
      ),
    );
  }

  Widget _actionCard(String title, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
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

  Widget _buildTransactionList(List items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Transactions récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("Tout voir", style: TextStyle(color: Colors.redAccent))),
            ],
          ),
          const SizedBox(height: 15),
          if (items.isEmpty) const Text("Aucune transaction trouvée"),
          ...items.take(4).map((item) => _transactionTile(item)).toList(),
        ],
      ),
    );
  }

  Widget _transactionTile(Map data) {
    bool isCredit = data['type'] == 2;
    Color color = isCredit ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCredit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: Icon(isCredit ? Icons.add : Icons.remove, color: color)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['description'] ?? "Transaction", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(data['date_transaction'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          Text("${isCredit ? '+' : '-'}${data['amount']} FCFA", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          _statCard("0", "Total reçu ce mois", Colors.green, const Color(0xFFE8F5E9)),
          const SizedBox(width: 15),
          _statCard("0", "Total retiré ce mois", Colors.red, const Color(0xFFFFF1F0)),
        ],
      ),
    );
  }

  Widget _statCard(String amount, String label, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Icon(color == Colors.green ? Icons.south_west : Icons.north_east, color: color),
            const SizedBox(height: 10),
            Text(amount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // --- WITHDRAWAL MODAL ---
  void _showWithdrawalModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder( // Important to allow modal to update its own state (like operator choice)
        builder: (context, setModalState) => Container(
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
                _buildModalHeader(context),
                const SizedBox(height: 20),
                _inputLabel("Montant à retirer (FCFA)"),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Ex : 10 000", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ["5000", "10000", "15000"].map((val) => _quickAmountChip(val, setModalState)).toList(),
                ),
                const SizedBox(height: 25),
                _inputLabel("Opérateur Mobile Money"),
                _operatorTile("Mixx by Yas", setModalState),
                _operatorTile("Moov Money", setModalState),
                const SizedBox(height: 25),
                _inputLabel("Numéro de dépôt"),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: "+228 XX XX XX XX", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                ),
                const SizedBox(height: 30),
                _buildConfirmButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(text: const TextSpan(style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black), children: [
          TextSpan(text: "Retrait ", style: TextStyle(color: Color(0xFFC2185B))),
          TextSpan(text: "sur Portefeuille"),
        ])),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _quickAmountChip(String val, StateSetter setModalState) {
    return InkWell(
      onTap: () => setModalState(() => _amountController.text = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(15)),
        child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _operatorTile(String name, StateSetter setModalState) {
    bool isSelected = _selectedOperator == name;
    return InkWell(
      onTap: () => setModalState(() => _selectedOperator = name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.grey[50],
          border: Border.all(color: isSelected ? const Color(0xFFC2185B) : Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFFC2185B)),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2185B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: () {
          // Logic to call withdrawal API
          ConfirmationModal.show(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Demande de retrait envoyée")));
        },
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_outline, color: Colors.white), SizedBox(width: 10), Text("Confirmer le retrait", style: TextStyle(color: Colors.white, fontSize: 16))
        ]),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)));
}