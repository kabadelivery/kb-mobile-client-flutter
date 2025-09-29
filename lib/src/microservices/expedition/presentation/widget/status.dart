import 'package:KABA/src/microservices/expedition/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Enums/status.dart';
class ExpeditionStepper extends StatelessWidget {
  final ExpeditionStatus currentStatus;

  const ExpeditionStepper({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    // ordre cohérent
    List<String> status = [
      "EN_ATTENTE",
      "ACCEPTEE",
      "PAIEMENT",
      "RECUPERATION_EFFECTUEE",
      "DEPART_CONFIRME",
      "EN_COURS_EXPEDITION",
      "ARRIVE_EN_VILLE",
      "LIVRAISON_AU_DESTINATAIRE"
    ];

    // si négociation fait partie du flux
    if (currentStatus.value == "NEGOCIATION") {
      status.insert(2, "NEGOCIATION");
    }

    // cas rejet
    if (currentStatus.value == "REJETEE") {
      status = ["REJETEE"];
    }

    final currentIndex = status.indexOf(currentStatus.value);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE93F53), Color(0xFFD52042)],
                ),
              ),
              child: const Icon(FontAwesomeIcons.truck, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 10),
            const Text(
              "Suivis étape par étape",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / status.length,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            color: KabaExpeditionColor.primary,
          ),
        ),
        Flexible(
          child: Column(
            children: status.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;

              Color? bgColor;
              Gradient? gradient;
              if (index < currentIndex) {
                gradient = const LinearGradient(
                  colors: [Color(0xFF37CD7A), Color(0xFF07A766)],
                );
              } else if (index == currentIndex) {
                gradient = const LinearGradient(
                  colors: [Color(0xFFE93F53), Color(0xFFD52042)],
                );
              } else {
                bgColor = Colors.grey[300];
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        gradient: gradient,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        value == "REJETEE"
                            ? Icons.close
                            : value == "EN_ATTENTE"
                            ? Icons.access_time_rounded
                            : value == "ACCEPTEE"
                            ? Icons.check_circle_outline_rounded
                            : value == "NEGOCIATION"
                            ? Icons.handshake_outlined
                            : value == "PAIEMENT"
                            ? Icons.receipt_outlined
                            : value == "RECUPERATION_EFFECTUEE"
                            ? FontAwesomeIcons.box
                            : value == "DEPART_CONFIRME"
                            ? Icons.check_circle_outline_rounded
                            : value == "EN_COURS_EXPEDITION"
                            ? FontAwesomeIcons.truck
                            : value == "ARRIVE_EN_VILLE"
                            ? Icons.location_on_outlined
                            : FontAwesomeIcons.box,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.replaceAll("_", " "),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: index == currentIndex
                                ? KabaExpeditionColor.primary
                                : index > currentIndex
                                ? Colors.grey
                                : const Color(0xFF07A766),
                          ),
                        ),
                        Text(
                          value == "REJETEE"
                              ? "Votre demande a été refusée"
                              : value == "EN_ATTENTE"
                              ? "En attente de traitement"
                              : value == "ACCEPTEE"
                              ? "Expedition acceptée"
                              : value == "NEGOCIATION"
                              ? "En cours de négociation"
                              : value == "PAIEMENT"
                              ? "Paiement confirmé"
                              : value == "RECUPERATION_EFFECTUEE"
                              ? "Récupération confirmée"
                              : value == "DEPART_CONFIRME"
                              ? "Confirmé par l'expéditeur"
                              : value == "EN_COURS_EXPEDITION"
                              ? "Colis en transit"
                              : value == "ARRIVE_EN_VILLE"
                              ? "Colis arrivé en ville"
                              : "Livré au destinataire",
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
