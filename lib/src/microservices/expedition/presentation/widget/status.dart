import 'package:KABA/src/microservices/expedition/core/utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Enums/status.dart';



class ExpeditionStepper extends StatelessWidget {
  final ExpeditionStatus currentStatus;

  const ExpeditionStepper({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = ExpeditionStatus.values;
    final currentIndex = steps.indexOf(currentStatus);

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
            gradient: LinearGradient(colors: [Color(0xFFE93F53), Color(0xFFD52042)],),
          ),
          child: Icon(FontAwesomeIcons.truck,color: Colors.white,size: 15,),
          ),
          SizedBox(width: 10,),
          Text("Suivis étape par étape",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87,fontSize: 16),)
        ],
      ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // 👈 round corners
          child: LinearProgressIndicator(
            value:(currentIndex+1) / steps.length,
            minHeight: 10, // 👈 make it thicker
            backgroundColor: Colors.grey.shade300,
            color: KabaExpeditionColor.primary,
          ),
        ),
        Flexible(
          child: Column(

            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final status = entry.value;
              Color? bgColor;
              Gradient? gradient;
              if (index < currentIndex) {
                // ÉTAPES PASSÉES = VERT
                gradient = const LinearGradient(
                  colors: [Color(0xFF37CD7A), Color(0xFF07A766)],
                );
              } else if (index == currentIndex) {
                // ÉTAPE ACTUELLE = ROUGE
                gradient = const LinearGradient(
                  colors: [Color(0xFFE93F53), Color(0xFFD52042)],
                );
              } else {
                // ÉTAPES FUTURES = GRIS
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
                        index==0?Icons.access_time_rounded:
                        index==1?Icons.check_circle_outline_rounded:
                        index==2?Icons.receipt_outlined:
                        index==3?FontAwesomeIcons.box:
                        index==4?Icons.check_circle_outline_rounded:
                        index==5?FontAwesomeIcons.truck:
                        index==6?Icons.location_on_outlined:
                        FontAwesomeIcons.box,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.value.replaceAll("_", " "),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: index == currentIndex
                                ? KabaExpeditionColor.primary
                                :index > currentIndex?Colors.grey :Color(0xFF07A766),
                          ),
                        ),
                        Text(index==0?"":
                        index==1?"Acceptée - Devis validé par le client":
                        index==2?"Paiement confirmé":
                        index==3?"Recupération confirmé":
                        index==4?"Confirmé par l'expéditeur":
                        index==5?"Colis en transit":
                        index==6?"Colis arrivé dans la destination (ville)":
                                     "En attente",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey
                        ),
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
