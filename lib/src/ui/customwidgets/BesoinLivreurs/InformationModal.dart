import 'package:flutter/material.dart';

class InformationModal {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Header Section ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFD61C4E),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.priority_high, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Informations importantes",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          Text("A lire avant de continuer",
                              style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              ),

              // --- Content Section ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoCard(
                      const Color(0xFFEBF2FF),
                      const Color(0xFF2E7DFF),
                      Icons.file_download_outlined,
                      "Les demandes de retrait se font lorsque vous n'avez aucune livraison en cours",
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      const Color(0xFFFFF7E6),
                      Colors.orange,
                      Icons.access_time,
                      "Les demandes de retrait se font après 24H. Si Kaba récupère de l'argent pour moi aujourd'hui, c'est le lendemain (07H30-17H30) que je peux faire une demande de retrait.",
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      const Color(0xFFE6F9F1),
                      const Color(0xFF00C569),
                      Icons.check_circle_outline,
                      "Les demandes de retrait sont traitées par notre équipe de comptabilité et finances. Le dépôt est effectué en 30 minutes max",
                    ),
                  ],
                ),
              ),

              // --- Footer Buttons ---
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler", style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD61C4E),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          // Handle "Continuer" action here
                          Navigator.pop(context);
                        },
                        child: const Text("Continuer", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildInfoCard(Color bgColor, Color iconColor, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}