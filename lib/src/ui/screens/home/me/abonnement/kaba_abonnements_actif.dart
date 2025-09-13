/* import 'package:flutter/material.dart';
import 'package:KABA/src/StateContainer.dart';
import 'package:KABA/src/contracts/order_details_contract.dart';
import 'package:KABA/src/contracts/transaction_contract.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/models/MoneyTransactionModel.dart';
import 'package:KABA/src/models/PointObjModel.dart';
import 'package:KABA/src/ui/customwidgets/abonnememts/SubscriptionCard.dart';

import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:KABA/src/utils/functions/Utils.dart';
import 'package:KABA/src/xrint.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class Kaba_abonnement_actif extends StatefulWidget {
  const Kaba_abonnement_actif({super.key});

  @override
  State<Kaba_abonnement_actif> createState() => _Kaba_abonnement_actifState();
}

class _Kaba_abonnement_actifState extends State<Kaba_abonnement_actif> {
  double progress = 0.33; // example state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: StateContainer.ANDROID_APP_SIZE,
          backgroundColor: KColors.primaryColor,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () {
                Navigator.pop(context);
              }),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // align to left
            mainAxisAlignment: MainAxisAlignment.center, // center vertically
            children: [
              SizedBox(height: 25),
              Text(
                  Utils.capitalize(
                      "${AppLocalizations.of(context)?.translate('T_suscription')}"),
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              Text(
                "Choissiez la formule qui vous convient",
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/background/Patternfond.png"), // your image
            fit: BoxFit.cover, // makes it cover full width + height
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 55, top: 35, right: 25), // top spacing
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center, // center the text
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Profitez des ", // line break before "Gratuite"
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text:
                                  "livraisons \n", // line break before "Gratuite"
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: "GRATUITES", // "Gratuite" in red
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: KColors.primaryColor, // red color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0), // left & right padding
                child: Card(
                  color: Colors.white,
                  elevation: 0.75, // shadow depth
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.5), // rounded corners
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 30.0,
                            bottom: 10.0), // padding around the row),
                        child: Row(
                          children: [
                            // Icon from assets

                            Image.asset(
                              "assets/images/png/abonnement-icons/Package.png",
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(width: 12), // spacing between icon & text

                            // First text
                           Column(
                            children:[
                               Text(
                              "Mon abonnement",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                             Text(
                              "Premium",
                              style: TextStyle( // spacing between texts
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            ]
                           ),

                            Spacer(), // pushes "Inactif" to the far right

                            // Status text with background, padding, and rounded edges
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Color(0xFFC5FFD9), // background color
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Actif",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00A63E), // text color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0), // internal padding
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F3F5), // grey background
                            borderRadius:
                                BorderRadius.circular(8), // small border radius
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, // small square container
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC8D4), // background color
                                  borderRadius: BorderRadius.circular(
                                      8), // rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // inner padding for the image
                                  child: Image.asset(
                                    "assets/images/png/abonnement-icons/Package.png", // your image
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Livraisons",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4), // spacing between texts
                                  Text(
                                    "50/150",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Rayon de livraison : 3Kms",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0), // internal padding
                          decoration: BoxDecoration(
                            color: Color(0xFFF3F3F5), // grey background
                            borderRadius:
                                BorderRadius.circular(8), // small border radius
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, // small square container
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC8D4), // background color
                                  borderRadius: BorderRadius.circular(
                                      8), // rounded corners
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // inner padding for the image
                                  child: SvgPicture.asset(
                                    "assets/images/png/abonnement-icons/Clock.svg", // your SVG file
                                    fit: BoxFit.contain,
                                    color: Color(
                                        0xFFCD1F45), // optional: change stroke color
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Expire dans",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 12), // spacing between texts
                                  Text(
                                    "15/08/25",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0), // internal padding
                          decoration: BoxDecoration(
                            color: Color(0xFFFFE9EE), // grey background
                            borderRadius:
                                BorderRadius.circular(8), // small border radius
                          ),
                          height: 240, // fixed width
                          child: Column(
                             children:[
                  
SizedBox(  height: 5),
        SizedBox(
  width: 300, // set your desired width here
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    onPressed: () {
      
    },
    icon: const Icon(Icons.code),
    label: const Text("Copier le code "),
  ),
),SizedBox(  height: 5),
        SizedBox(
  width: 300, // set your desired width here
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    onPressed: () {},
    icon: const Icon(Icons.link),
    label: const Text("Copier le Lien"),
  ),
),
SizedBox(  height: 5),
SizedBox(
  width: 300, // set your desired width here
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    onPressed: () {},
    icon: const Icon(Icons.share),
    label: const Text("Partager"),
  ),
),SizedBox(  height: 5),
            SizedBox(
  width: 300, // set your desired width here
  child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      
      side: const BorderSide(color: Colors.red),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    onPressed: () {},
    
    label: const Text("Code : CPMFRS2025 • Places restantes : 2"),
  ),
),


                               
                             ]
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  SubscriptionCard(
                    title: "BASIC",
                    price: "2.500",
                    borderColor: Color(0xFF155DFC),
                    accentColor: Color(0xFF155DFC),
                    features: [
                      "10 livraisons",
                      "Rayon de 3Kms",
                      "Min. 1.000 F",
                      "Valide 25 jours",
                      "Partageable",
                    ],
                  ),
                  SubscriptionCard(
                    title: "BASIC +",
                    price: "5.000",
                    borderColor: Colors.green,
                    accentColor: Colors.green,
                    features: [
                      "20 livraisons",
                      "Rayon de 6Kms",
                      "Min. 1.000 F",
                      "Valide 25 jours",
                      "Partageable",
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 10),
                  SubscriptionCard(
                    title: "BASIC",
                    price: "2.500",
                    borderColor: Color(0xFFD99507),
                    accentColor: Color(0xFFD99507),
                    features: [
                      "10 livraisons",
                      "Rayon de 3Kms",
                      "Min. 1.000 F",
                      "Valide 25 jours",
                      "Partageable",
                    ],
                  ),
                  SubscriptionCard(
                    title: "BASIC +",
                    price: "5.000",
                    borderColor: Color(0xFFC57AFB),
                    accentColor: Color(0xFFC57AFB),
                    features: [
                      "20 livraisons",
                      "Rayon de 6Kms",
                      "Min. 1.000 F",
                      "Valide 25 jours",
                      "Partageable",
                    ],
                  ),
                ],
              ),
              SubscriptionCard(
                title: "VIC",
                width: 300,
                price: "100000",
                borderColor: Color(0xFFCD1F45),
                accentColor: Color(0xFFCD1F45),
                features: [
                  "20 livraisons",
                  "Rayon de 6Kms",
                  "Min. 1.000 F",
                  "Valide 25 jours",
                  "Partageable",
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 */