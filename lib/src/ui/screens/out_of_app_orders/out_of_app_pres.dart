import 'package:KABA/src/utils/_static_data/AppConfig.dart';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../localizations/AppLocalizations.dart';
import '../../../microservices/expedition/presentation/pages/tracking_package.dart';
import '../../../microservices/expedition/presentation/widget/contact.dart';
import '../../../microservices/kaba_chine/functions/contact.dart';
import '../../../utils/functions/OutOfAppOrder/resetProviders.dart';
import '../../customwidgets/out_of_app_product_form_widget.dart';

class OutOfAppPres extends ConsumerStatefulWidget {
  const OutOfAppPres({super.key});

  @override
  ConsumerState<OutOfAppPres> createState() => _OutOfAppPresState();
}

class _OutOfAppPresState extends ConsumerState<OutOfAppPres> {
  bool reset = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (reset) {
        resetProviders(ref);
        reset = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      "https://cdn.prod.website-files.com/668e33655e63d7cdd7ed90ef/6785f19ec0f6dc1aa571a103_jack-lee-ih65r4heqwq-unsplash_758edd9ece38dca2f0a8a4e42a98ee41_800.jpeg", // use the https link of image0
      "https://assets.farmjournal.com/dims4/default/30c1d41/2147483647/strip/true/crop/840x473+0+64/resize/1440x810!/quality/90/?url=https%3A%2F%2Ffj-corp-pub.s3.us-east-2.amazonaws.com%2Fs3fs-public%2F2023-09%2FTops-main1.png", // use the link from image1
      "https://www.netguru.com/hubfs/Store%20with%20clothes.jpg",
    ];


    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width:MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 20,right: 20,bottom: 10,top: 60),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                  color: KColors.primaryColor
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_sharp,color: Colors.white,size: 19,)),
                      SizedBox(width: 5,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("KABA HORS APPLI",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        showBottomContactSheet(context: context, number: '+228${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}');
                      }, icon: Icon(Icons.phone_outlined,color: Colors.white,)),
                      IconButton(onPressed: (){
                        contactWhatsApp(phoneNumber: "${AppConfig.CUSTOMER_CARE_PHONE_NUMBER}", message: "${AppLocalizations.of(context)!.translate('i_have_an_inquiry')}");
                      }, icon: Icon(Icons.messenger_outline,color: Colors.white,)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: images.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.network(url, fit: BoxFit.cover, width: 1000)),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // --- Service Card ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre + icône pilule
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFD02245),
                                Color(0xFFE43746)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(FontAwesomeIcons.store,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Service d'achat hors application",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              "Commandez n'importe où et n'importe quoi",
                              style: TextStyle(
                                  color: KColors.primaryColor,fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      "Passez des commandes dans n'importe quelle boutique/superette/supermarché de votre choix, même si elle n'est pas référencée sur notre plateforme.",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),

                    const SizedBox(height: 16),

                    // --- Boutons secondaires ---
                    Column(
                      children: [
                        _FeatureButton(
                          icon: Icons.shield_outlined,
                          text: "Service sécurisé et professionnel",
                        ),
                        const SizedBox(height: 10),
                        _FeatureButton(
                          icon: Icons.local_shipping_outlined,
                          text: "Livraison rapide à domicile",
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- Bouton principal ---
                    GestureDetector(
                      onTap: (){
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * .6,
                                child: OutOfAppProductForm(),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFCB1F44),
                              Color(0xFFE83C61)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        alignment: Alignment.center,
                        height: 50,
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined,color: Colors.white,),
                            SizedBox(width: 10,),
                            Text(
                              "Acheter un produit",
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),

            // --- Info Box ---
            Container(
              width: 350,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE9ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFB1C3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: KColors.primaryColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Commandez depuis des boutiques/supermarchés non référencées sur notre plateforme",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
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

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureButton({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDF2),
        border: Border.all(color: Color(0xFFEF97AA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0x3DCB1F44),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Color(0xFFCB1F44))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}
