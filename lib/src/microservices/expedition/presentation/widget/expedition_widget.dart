import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/microservices/expedition/core/utils.dart';
import 'package:KABA/src/microservices/expedition/presentation/widget/status.dart';
import 'package:KABA/src/microservices/expedition/presentation/widget/tracked_package_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Enums/status.dart';
import '../../data/expedition/expedition_model.dart';

Widget ExpeditionWidget({required BuildContext context,required ExpeditionModel expedition}) {
  List status = [
    "EN_ATTENTE",
    "ACCEPTEE",
    "NEGOCIATION",
    "PAIEMENT",
    "RECUPERATION_EFFECTUEE",
    "DEPART_CONFIRME",
    "EN_COURS_EXPEDITION",
    "ARRIVE_EN_VILLE",
    "LIVRAISON_AU_DESTINATAIRE"
  ];
  int indexOfStatus = status.indexOf(expedition.status)+1;
  if(expedition.status == "REJETEE"){
    status = [
      "REJETEE",
    ];
  }
  return Container(
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${expedition.trackingNumber!.substring(0,10)}...",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(expedition.colisDetail!.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14
                            )
                        ),
                      ],
                    ),

                  ],
                ),

              ],
            ),
            GestureDetector(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(

                        backgroundColor: Colors.white,
                        content: SizedBox(
                          height: 660,
                          width: double.maxFinite,
                          child: ExpeditionStepper(currentStatus: ExpeditionStatus.values.where((element) => element.name == expedition.status).first),
                        ),
                      );
                    });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: KabaExpeditionColor.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  Text(
                  "${expedition.status==ExpeditionStatus.EN_COURS_EXPEDITION.value?"En cours d'expedition":
                  expedition.status==ExpeditionStatus.ARRIVE_EN_VILLE.value?"Arrivé à ville":
                  expedition.status==ExpeditionStatus.LIVRAISON_AU_DESTINATAIRE.value?"Livraison au destinataire":
                  expedition.status==ExpeditionStatus.DEPART_CONFIRME.value?"Départ confirmé":
                  expedition.status==ExpeditionStatus.PAIEMENT.value?"Paiement":
                  expedition.status==ExpeditionStatus.NEGOCIATION.value?"Negotiation":
                  expedition.status==ExpeditionStatus.RECUPERATION_EFFECTUEE.value?"Récupération effectuée":
                  expedition.status==ExpeditionStatus.EN_ATTENTE.value?"Demande faite":
                  expedition.status==ExpeditionStatus.ACCEPTEE.value?"Acceptée"
                      :
                  expedition.status==ExpeditionStatus.REJETEE.value?"Rejetée"
                      :"Status inconnu"
                  }",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Route info
        Row(
          children: [
            Icon(Icons.location_on, color: KabaExpeditionColor.primary, size: 20),
            SizedBox(width: 6),
            Text("${expedition.ligne!.depart!.nom}, ${expedition.ligne!.depart!.pays!["nom"]} → ${expedition.ligne!.arrivee!.nom}, ${expedition.ligne!.arrivee!.pays!['nom']}"),
          ],
        ),

        const SizedBox(height: 12),

        // Progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Progression"),
            Text("$indexOfStatus /${status.length} étapes"),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10), // 👈 round corners
          child: LinearProgressIndicator(
            value: indexOfStatus / status.length,
            minHeight: 12, // 👈 make it thicker
            backgroundColor: Colors.grey.shade300,
            color: KabaExpeditionColor.primary,
          ),
        ),

        const SizedBox(height: 12),

        // Estimated delivery
        Row(
          children: [
            Icon(Icons.access_time, color: KabaExpeditionColor.primary, size: 20),
            SizedBox(width: 6),
            Text(
              "Livraison estimée dans ${expedition.estimatedDelivery!.difference(DateTime.now()).inDays} jours",
              style: TextStyle(color: KabaExpeditionColor.primary, fontWeight: FontWeight.w500),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Last update & amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dernière mise à jour"),
                Text("${expedition.updatedAt!.day<10?"0"+expedition.updatedAt!.day.toString() : expedition.updatedAt!.day}/${expedition.updatedAt!.month<10?"0"+expedition.updatedAt!.month.toString(): expedition.updatedAt!.month}/${expedition.updatedAt!.year}",
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Montant"),
                if(expedition.colisDetail!.reductionAppliquee!=0 && expedition.colisDetail!.reductionAppliquee!=null)
                  Text("${expedition.colisDetail!.prixBase} FCFA",
                      style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("${expedition.colisDetail!.prixFinal} FCFA",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: KabaExpeditionColor.primary)),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(

            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: KabaExpeditionColor.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => TrackingPackage(expeditionModel: expedition,),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var begin = Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end);
                    var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);
                    return SlideTransition(
                        position: tween.animate(curvedAnimation),
                        child: child
                    );
                  }
              ));

            },
            child:  Text("${AppLocalizations.of(context)!.translate('see_detailed_tracking')}"),
          ),
        )
      ],
    ),
  );
}