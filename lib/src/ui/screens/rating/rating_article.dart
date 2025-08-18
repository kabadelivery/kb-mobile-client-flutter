import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../blocs/rating/rating_bloc.dart';
import '../../../models/DeliveryRatingPending.dart';
import '../../../utils/Enums/DeliveryRatingType.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../customwidgets/rating_widget.dart';

class RatingArticle extends StatefulWidget {
  final DeliveryRatingPending deliveryRatingPending;
  const RatingArticle({required this.deliveryRatingPending, super.key});

  @override
  State<RatingArticle> createState() => _RatingArticleState();
}

class _RatingArticleState extends State<RatingArticle> {
  String sellerName = "DaVodou";
  String sellerImage = "https://t3.ftcdn.net/jpg/01/97/11/64/360_F_197116416_hpfTtXSoJMvMqU99n6hGP4xX0ejYa4M7.jpg";
  String articleName = "";
  int totalRating = 3;
  TextEditingController commentController = TextEditingController();
  @override
void initState() {
    super.initState();
    sellerImage = widget.deliveryRatingPending.seller_image!;
    sellerName = widget.deliveryRatingPending.seller_name!;
    articleName = widget.deliveryRatingPending.article_name!;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Background header
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              decoration: BoxDecoration(
                color: KColors.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
            ),

            // Moved this out of Container and into Stack
            Positioned(
              top: 40,
              left: (MediaQuery.of(context).size.width -120)/2,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Colors.white,
                    width: 10.0,
                  ),
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage("$sellerImage")),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: KColors.primaryColor,
                      width: .5,
                    ),
                  ),
                ),
              ),
            ),
            // Bottom section
            Positioned(
              top: MediaQuery.of(context).size.height * 0.20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Marchant",
                        style: TextStyle(fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.black87),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        sellerName,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 12, color: Colors.black87),

                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                   Container(
                     width: 350,
                     child: GestureDetector(
                       child: Row(
                         children: [
                           Icon(Icons.arrow_back_ios, size: 15, color: Colors.black87),
                           Flexible(
                             child: Text(
                              "Que pensez-vous de votre dernier achat chez $sellerName?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 15, color: Colors.black87),
                      const SizedBox(width: 5),
                      Text(
                        "${articleName}",
                        style: TextStyle(fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.black87),

                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                  RatingWidget(
                    context: context,
                    ratingTextAndIcon: Container(),
                    rate_id: DeliveryRatingType.ratingAricle,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width:MediaQuery.of(context).size.width * 0.8,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: TextFormField(
                          maxLines: 1,
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: "Ajouter un commentaire sur l'article",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: KColors.primaryColor, width: 1.0),
                              ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: KColors.primaryColor, width: 1.0),
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: KColors.primaryColor,
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.refresh, size: 20, color: Colors.white),
                          const SizedBox(width: 5),
                          Text("Repasser la même commande",
                            style: TextStyle(fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                     ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text("Retour au menu d'achat",
                      style: TextStyle(fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: KColors.primaryColor),
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
