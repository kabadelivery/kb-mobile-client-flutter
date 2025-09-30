import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/_static_data/KTheme.dart';

class PerformanceCard extends StatelessWidget {
  final double currentRating;
  final int reviewCount;
  final double speed;
  final double geolocationRespect;
  final double attitude;
  final double appearance;

  const PerformanceCard({
    super.key,
    required this.currentRating,
    required this.reviewCount,
    required this.speed,
    required this.geolocationRespect,
    required this.attitude,
    required this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header rouge
            Container(
              height: 80,
              decoration:  BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Stack(
                  children: [
                    Positioned(child: Image.asset('assets/images/png/Zap.png',width:40),
                        top: 10,right: 10),
                    const Row(
                      children: [
                        Icon(FontAwesomeIcons.boltLightning, color: Colors.orangeAccent, size: 25),
                        Flexible(
                          child: Text(
                            "Performance en temps réel de l’appli Kaba",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contenu blanc
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sentiment_satisfied_alt, color:KColors.primaryColor),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              "Note actuelle",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color:Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text("${currentRating.toStringAsFixed(1)}",style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color:KColors.primaryColor,
                            )),
                            const SizedBox(width: 8),
                            Text("/5",style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:Colors.black87,
                            )),

                          ],
                        ),
                      ],
                    ),
                    Text(
                      "Basé sur $reviewCount avis",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    _buildMetric(Icons.speed, "Rapidité", speed),
                    _buildMetric(Icons.location_on, "Respect de Géolocalisation", geolocationRespect),
                    _buildMetric(Icons.tag_faces, "Attitude des livreurs", attitude),
                    _buildMetric(Icons.person, "Aspect/Image des livreurs", appearance),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: KColors.primaryColor,width: 0.5)
                        ),
                      ),
                      child: const Text(
                        "Compris",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(IconData icon, String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
