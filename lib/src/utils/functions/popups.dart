import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kkiapay_flutter_sdk/utils/config.dart' as KColors;

import '../../localizations/AppLocalizations.dart';

import 'dart:ui';
import 'package:flutter/material.dart';

Future<void> showModernPopup({
  required BuildContext context,
  required String title,
  required String text,
  required Icon icon,
  Color accentColor = const Color(0xFFD02245),
}) {
  return showGeneralDialog(
    context: context,
    barrierLabel: "Popup",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return Transform.scale(
        scale: Tween<double>(begin: 0.92, end: 1).evaluate(curved),
        child: Opacity(
          opacity: animation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.92),
                        Colors.white.withOpacity(0.84),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                      BoxShadow(
                        color: accentColor.withOpacity(0.10),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accentColor.withOpacity(0.20),
                                accentColor.withOpacity(0.08),
                              ],
                            ),
                            border: Border.all(
                              color: accentColor.withOpacity(0.18),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: icon
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            letterSpacing: -0.4,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4B5563),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withOpacity(0.85),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentColor.withOpacity(0.28),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .translate('close'),
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
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
      child: Container(
        width: MediaQuery.of(context).size.width ,
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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Text(
                              "de votre commande:",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            SizedBox(width: 5),

                            Text(
                              "$preparationTime minutes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD02245),
                              ),
                            ),
                          ],
                        ),
                      )
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