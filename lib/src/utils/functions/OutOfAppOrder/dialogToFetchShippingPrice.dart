import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../../localizations/AppLocalizations.dart';
import 'launchOrder.dart';
import 'out_of_app_sharedPref.dart';

Future<bool?> showShippingPriceRangeInfo(
    BuildContext context, WidgetRef ref, int type_of_order) async {
  // récupère min/max depuis les prefs (fallback "?")
  Map<String, dynamic> prices = await OutOfAppSharedPrefs.getStringMap();
  String minPrice = prices["minimum"]?.toString() ?? "?";
  String maxPrice = prices["maximum"]?.toString() ?? "?";

  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // carré icône dégradé
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFCB1F44),
                      Color(0xFFD13457)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(
                    Icons.query_stats,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Fluctuation du prix",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Description (avec min/max mis en évidence)
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!
                          .translate('the_shipping_price_can_change') ??
                          "Le prix de livraison peut varier entre ",
                    ),
                    TextSpan(
                      text: " $minPrice ",
                      style: TextStyle(
                        color:Color(0xFFCB1F44),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: AppLocalizations.of(context)!.translate('and') ??
                          " et ",
                    ),
                    TextSpan(
                      text: " $maxPrice ",
                      style: TextStyle(
                        color:Color(0xFFCB1F44),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: " ${AppLocalizations.of(context)!.translate('depending_on_store_location') ?? 'selon la localisation du magasin'}.",
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Bouton principal (Next / Confirmer)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD13457),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                     label: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate('next') ??
                            "Suivant",
                        style:
                        const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Bouton secondaire (Annuler / Pas maintenant)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('cancel') ??
                        "Annuler",
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result;
}
