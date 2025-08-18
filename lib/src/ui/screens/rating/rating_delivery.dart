import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../blocs/rating/rating_bloc.dart';
import '../../../models/DeliveryRatingPending.dart';
import '../../../utils/Enums/DeliveryRatingType.dart';
import '../../customwidgets/rating_widget.dart';

class RatingDelivery extends StatefulWidget {
  final DeliveryRatingPending deliveryRatingPending;
  const RatingDelivery({required this.deliveryRatingPending, super.key});
  @override
  State<RatingDelivery> createState() => _RatingDeliveryState();
}

class _RatingDeliveryState extends State<RatingDelivery> {
  String livreurName = "";
  String livreurImage = "https://images.icon-icons.com/3560/PNG/512/delivery_courier_man_people_avatar_shipping_icon_225197.png";
  int speedRating =3;
  int respectOfGeolocation = 3;
  int attidudeOfDeliveryMan = 3;
  int groomingOfDeliveryMan = 3;
  double totalRating = 3;
  int cumulRating = 12;
  @override
  void initState(){
    super.initState();
    livreurImage = widget.deliveryRatingPending.delivery_man_image!;
    livreurName = widget.deliveryRatingPending.delivery_man_name!;
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
                        image: NetworkImage("${livreurImage.isEmpty?"https://images.icon-icons.com/3560/PNG/512/delivery_courier_man_people_avatar_shipping_icon_225197.png":livreurImage}")
                    ),
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
              top: MediaQuery.of(context).size.height * 0.25,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Livreur",
                        style: TextStyle(fontWeight: FontWeight.normal,
                            fontSize: 10,
                            color: Colors.black87),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        livreurName,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 10, color: Colors.black87),

                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Text(
                    "Comment s'est passé votre dernière livraison ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RatingWidget(
                    context: context,
                    ratingTextAndIcon: SizedBox(
                      width: 120,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.time, weight: .5, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("Rapidité", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate_id: DeliveryRatingType.speedRating,
                  ),
                  RatingWidget(
                    context: context,
                    ratingTextAndIcon: SizedBox(
                      width: 120,
                      child: Row(
                        children:  [
                          Icon(Icons.location_on_outlined, weight: 100, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("Respect de la géolocalisation", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate_id: DeliveryRatingType.respectOfGeolocation,
                  ),
                  RatingWidget(
                    context: context,
                    ratingTextAndIcon: SizedBox(
                      width: 100,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.smiley, weight: .5, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("Attitude du livreur", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate_id: DeliveryRatingType.attidudeOfDeliveryMan,
                  ),
                  RatingWidget(
                    context: context,
                    ratingTextAndIcon: SizedBox(
                      width: 100,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.person, weight: 0.1, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("Tenue du livreur", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate_id: DeliveryRatingType.groomingOfDeliveryMan,
                  ),
                  const SizedBox(height: 10),
                  BlocSelector<RatingBloc, RatingState, RatingState>(
                    selector: (state) => state,
                    builder: (context, state) {
                      if (state is RateDeliveryTypeState) {
                        speedRating = state.deliveryRatingType == DeliveryRatingType.speedRating ? state.rating : speedRating;
                        respectOfGeolocation = state.deliveryRatingType == DeliveryRatingType.respectOfGeolocation ? state.rating : respectOfGeolocation;
                        attidudeOfDeliveryMan = state.deliveryRatingType == DeliveryRatingType.attidudeOfDeliveryMan ? state.rating : attidudeOfDeliveryMan;
                        groomingOfDeliveryMan = state.deliveryRatingType == DeliveryRatingType.groomingOfDeliveryMan ? state.rating : groomingOfDeliveryMan;
                        cumulRating = speedRating + respectOfGeolocation + attidudeOfDeliveryMan + groomingOfDeliveryMan;
                        totalRating = cumulRating / 4;
                      }
                      return Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(totalRating<3?FontAwesomeIcons.faceFrown:FontAwesomeIcons.faceSmile, weight: .5, size:19,color: KColors.primaryColor),
                            const SizedBox(width: 5),
                            const Flexible(child: Text("Note Totale :", style: TextStyle(fontSize:14,color: Colors.black87))),
                            const SizedBox(width: 5),
                            Container(
                              width: 50,
                              child: Text(
                                totalRating.toString(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
