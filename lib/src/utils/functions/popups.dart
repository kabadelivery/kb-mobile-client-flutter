import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

Future<void> showModernPopup({
  required BuildContext context,
  required String text,
  required Icon icon,
}) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD02245),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Fermer"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
class PreparationPopup extends StatelessWidget {
  final int preparationTime; // in minutes

  const PreparationPopup({super.key, required this.preparationTime});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            // Header Stack
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: const [
                        SizedBox(height: 20),
                        Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFD02245), size: 50),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Image.asset("assets/images/png/horloge.png", width: 160),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        SizedBox(height: 20),
                        Opacity(
                          opacity: .3,
                          child: Image(
                            image: AssetImage("assets/images/png/horloge.png"),
                            width: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Title + dynamic time
                Positioned(
                  bottom: 40,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      const Text(
                        "Temps de préparation maximum",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "de votre commande:",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "$preparationTime minutes",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFFD02245),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Disclaimer + Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFFD02245), size: 17),
                       Flexible(
                         child: Text(
                          "Ce temps ne dépend en aucun cas de KABA.\n"
                              "Le marchand accepte faire tout son possible afin de le respecter.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFFD02245),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                                               ),
                       ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(

                        onPressed: () =>  Navigator.of(context).pop({'success': false}),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side:  BorderSide(color: Color(0xFFD02245).withOpacity(.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop({'success': true});

                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Color(0xFFD02245),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Poursuivre"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}