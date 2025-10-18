import 'package:flutter/material.dart';

bool detectTogoMomoOperator(String phoneNumber) {
  phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
  if (phoneNumber.length > 8) {
    phoneNumber = phoneNumber.substring(phoneNumber.length - 8);
  }

  if (phoneNumber.length != 8) {
    return false;
  }

  String prefix = phoneNumber.substring(0, 2);

  const List<String> tmoneyPrefixes = ['70', '71', '72', '73', '90', '91', '92', '93'];
  const List<String> floozPrefixes  = ['79', '96', '97', '98', '99'];

  if (tmoneyPrefixes.contains(prefix)) {
    return true;
  }

  if (floozPrefixes.contains(prefix)) {
    return true;
  }

  return false;
}
Future<Map<String, dynamic>> checkPaymentStatus(
    BuildContext context, {
      String title = "Validez",
      String message =
      "Une fois le paiement validé, vous recevrez une notification concernant l'activation de votre abonnement.",
      bool barrierDismissible = false,
    })
async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        backgroundColor: Colors.transparent, // pour un look "flat"
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: theme.cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bandeau rouge en haut
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  color: Color(0xffcb1f44),
                  child: Row(
                    children: [
                      Icon(Icons.payment, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Contenu
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                    ],
                  ),
                ),

                // Actions (flat)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                         Navigator.pop(context);
                        },
                        child: Text(
                          "COMPRIS",
                          style: TextStyle(
                            color:Color(0xffcb1f44),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? {'status': 'dismissed'};
}