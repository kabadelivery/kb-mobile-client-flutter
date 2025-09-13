import 'package:KABA/src/ui/customwidgets/abonnememts/SingleSelectList.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/material.dart';
 // 👈 import your SingleSelectList file

class SubscriptionBottomSheet extends StatefulWidget {
  final int idPack;
  final String title;
  final String price;
  final String currency;
  final Color accentColor;

  const SubscriptionBottomSheet({
    Key? key,
    required this.idPack,
    required this.title,
    required this.price,
    required this.currency,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<SubscriptionBottomSheet> createState() =>
      _SubscriptionBottomSheetState();

  // 👇 Helper to show it
  static void show(
    BuildContext context, {
    required int idPack,
    required String title,
    required String price,
    required String currency,
    required Color accentColor,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SubscriptionBottomSheet(
        idPack: idPack,
        title: title,
        price: price,
        currency: currency,
        accentColor: accentColor,
      ),
    );
  }
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  int? selectedIndex;
  String? selectedMethodLabel;

  // Example items for SingleSelectList
  final items = [
    ListItem(title: "Mobile Money", subtitle: "TMoney, MTN, Wave…", icon: Icons.phone_android),
    ListItem(title: "Carte Bancaire", subtitle: "Visa, MasterCard", icon: Icons.credit_card),
    ListItem(title: "PorteFeuille KABA", subtitle: "Votre solde KABA", icon: Icons.account_balance_wallet),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER
              const Text(
                "Facture d'abonnement",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Vérifiez les détails de votre abonnement et procédez au paiement sécurisé",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 20),

              // --- SUBSCRIPTION DETAILS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: widget.accentColor.withOpacity(0.1),
                  border: Border.all(color: widget.accentColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("${widget.price} ${widget.currency}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCD1F45),
                            )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("10 livraisons"),
                    ]),
                    Row(children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Valide 25 jours"),
                    ]),
                    Row(children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Rayon de 3Kms"),
                    ]),
                    Row(children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 6),
                      Text("Min. 1000 F"),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- FACTURATION DETAILS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Détails de la facturation",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Prix de base"),
                        Text("${widget.idPack}"),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 15),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Prix de base"),
                        Text("${widget.price}",style: TextStyle(color: KColors.primaryColor),),
                      ],
                    )
                  ,
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- PAYMENT METHODS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Choisissez la méthode de paiement",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    // --- SingleSelectList
                    SingleSelectList(
                      items: items,
                      onChanged: (i) {
                        setState(() => selectedIndex = i);
                      },
                      onItemSelected: (label) {
                        setState(() => selectedMethodLabel = label);
                      },
                    ),

                    const Divider(),

                    // --- Selected Method Display
                    if (selectedMethodLabel != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: Text(
                          selectedMethodLabel!,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                      )
                    else
                      const Text("Veuillez sélectionner une méthode 👆",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- ACTION BUTTONS
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD1F45),
                    ),
                    onPressed: () {
                      if (selectedMethodLabel == null) {
                       debugPrint("No Payement Selected");
                      }
                      // 👇 continue payment with selectedMethodLabel
                      debugPrint("Pay with $selectedMethodLabel");
                    },
                    child: const Text("Payer ",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
