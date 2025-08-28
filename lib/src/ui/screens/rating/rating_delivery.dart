import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../blocs/rating/rating_bloc.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/CustomerModel.dart';
import '../../../models/DeliveryRatingPending.dart';
import '../../../resources/order_api_provider.dart';
import '../../../utils/Enums/DeliveryRatingType.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../../utils/functions/new_rating_feature.dart';
import '../../customwidgets/rating_widget.dart';

class RatingDelivery extends StatefulWidget {
  final DeliveryRatingPending deliveryRatingPending;
  final bool deleteAll;
  const RatingDelivery({required this.deliveryRatingPending, required this.deleteAll, super.key});
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
  TextEditingController commentController = TextEditingController();
  @override
  void initState(){
    super.initState();
    livreurImage = widget.deliveryRatingPending.delivery_man_image!;
    livreurName = widget.deliveryRatingPending.delivery_man_name!;
    speedRating = widget.deliveryRatingPending.speedRating ?? 3;
    respectOfGeolocation = widget.deliveryRatingPending.respectOfGeolocation ?? 3;
    attidudeOfDeliveryMan = widget.deliveryRatingPending.attidudeOfDeliveryMan ?? 3;
    groomingOfDeliveryMan = widget.deliveryRatingPending.groomingOfDeliveryMan ?? 3;
    cumulRating = speedRating + respectOfGeolocation + attidudeOfDeliveryMan + groomingOfDeliveryMan;
    totalRating = cumulRating / 4;
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
              left: 100,
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
                       Text(
                        "${AppLocalizations.of(context)!.translate("delivery_person")}",
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
                   Text(
                     "${AppLocalizations.of(context)!.translate("delivery_feedback")}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RatingWidget(
                    ratingTextAndIcon: SizedBox(
                      width: 120,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.time, weight: .5, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text( "${AppLocalizations.of(context)!.translate("delivery_speed")}", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate_id: DeliveryRatingType.speedRating,
                    rate: speedRating,

                  ),
                  RatingWidget(
                    ratingTextAndIcon: SizedBox(
                      width: 120,
                      child: Row(
                        children:  [
                          Icon(Icons.location_on_outlined, weight: 100, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("${AppLocalizations.of(context)!.translate("delivery_geolocation")}", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate: respectOfGeolocation,
                    rate_id: DeliveryRatingType.respectOfGeolocation,
                  ),
                  RatingWidget(
                    ratingTextAndIcon: SizedBox(
                      width: 100,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.smiley, weight: .5, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("${AppLocalizations.of(context)!.translate("delivery_attitude")}", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate: attidudeOfDeliveryMan,
                    rate_id: DeliveryRatingType.attidudeOfDeliveryMan,
                  ),
                  RatingWidget(
                    ratingTextAndIcon: SizedBox(
                      width: 100,
                      child: Row(
                        children:  [
                          Icon(CupertinoIcons.person, weight: 0.1, color: Colors.black87),
                          SizedBox(width: 5),
                          Flexible(child: Text("${AppLocalizations.of(context)!.translate("delivery_uniform")}", style: TextStyle(color: Colors.black87,fontSize: 12))),
                        ],
                      ),
                    ),
                    rate: groomingOfDeliveryMan,
                    rate_id: DeliveryRatingType.groomingOfDeliveryMan,
                  ),
                  BlocSelector<RatingBloc, RatingState, RatingState>(
                    selector: (state) => state,
                    builder: (context, state) {
                      if (state is RateDeliveryTypeState) {

                        if(state.deliveryRatingType == DeliveryRatingType.speedRating) {
                          speedRating = state.rating;
                        }
                        if(state.deliveryRatingType == DeliveryRatingType.respectOfGeolocation) {
                          respectOfGeolocation = state.rating;
                        }
                        if(state.deliveryRatingType == DeliveryRatingType.attidudeOfDeliveryMan) {
                          attidudeOfDeliveryMan = state.rating;
                        }
                        if(state.deliveryRatingType == DeliveryRatingType.groomingOfDeliveryMan) {
                          groomingOfDeliveryMan = state.rating;
                        }
                         cumulRating = speedRating + respectOfGeolocation + attidudeOfDeliveryMan + groomingOfDeliveryMan;
                        totalRating = cumulRating / 4;
                      }
                      if(state is PreviousPageState){
                        speedRating = state.deliveryRatingPending.speedRating ?? 3;
                        respectOfGeolocation = state.deliveryRatingPending.respectOfGeolocation ?? 3;
                        attidudeOfDeliveryMan = state.deliveryRatingPending.attidudeOfDeliveryMan ?? 3;
                        groomingOfDeliveryMan = state.deliveryRatingPending.groomingOfDeliveryMan ?? 3;
                        cumulRating = speedRating + respectOfGeolocation + attidudeOfDeliveryMan + groomingOfDeliveryMan;
                        totalRating = cumulRating / 4;
                        commentController.text=state.deliveryRatingPending.delivery_comment??"";

                      }
                      return Container(
                        width: MediaQuery.of(context).size.width*0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(totalRating<3?FontAwesomeIcons.faceFrown:totalRating>=3&& totalRating<4?FontAwesomeIcons.faceSmile:totalRating>=4&& totalRating<5?FontAwesomeIcons.faceSmileWink:totalRating>=5?FontAwesomeIcons.faceSmileBeam:FontAwesomeIcons.faceSmileBeam, weight: .5, size:19,color: KColors.primaryColor),
                            const SizedBox(width: 5),
                             Flexible(child: Text("${AppLocalizations.of(context)!.translate("total_score")}", style: TextStyle(fontSize:14,color: Colors.black87))),
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
                  ),

                   Container(
                    width:MediaQuery.of(context).size.width * 0.8,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: TextFormField(
                          maxLines: 1,
                          controller: commentController,
                          decoration: InputDecoration(

                            hintText: "${AppLocalizations.of(context)!.translate("add_comment")}",
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
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
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    onPressed: ()async {
                      DeliveryRatingPending deliveryRatingPending = DeliveryRatingPending();
                      deliveryRatingPending = widget.deliveryRatingPending;
                      deliveryRatingPending.delivery_rating = totalRating;
                      deliveryRatingPending.delivery_comment = commentController.text;
                      deliveryRatingPending.speedRating = speedRating;
                      deliveryRatingPending.respectOfGeolocation = respectOfGeolocation;
                      deliveryRatingPending.attidudeOfDeliveryMan = attidudeOfDeliveryMan;
                      deliveryRatingPending.groomingOfDeliveryMan = groomingOfDeliveryMan;

                      if(widget.deliveryRatingPending.articles!.length>1){
                        deliveryRatingPending.article_comment = commentController.text;
                        deliveryRatingPending.article_rating = totalRating.toDouble();
                        if(widget.deliveryRatingPending.articles!.length>1){
                          widget.deliveryRatingPending.article_rating=0.0;
                          deliveryRatingPending.articles=    widget.deliveryRatingPending.articles!.map((el){
                            el["rating"]=0;
                            return el;
                          }).toList();
                        }else{
                          deliveryRatingPending.articles!.first={
                            "id": widget.deliveryRatingPending.articles!.first['id'],
                            "name": widget.deliveryRatingPending.articles!.first['name'],
                            "rating": totalRating,
                          };
                        }
                    }
                      BlocProvider.of<RatingBloc>(context).add(
                        sendDeliveryRatingPendingEvent(deliveryRatingPending: deliveryRatingPending),
                      );
                      BlocProvider.of<RatingBloc>(context).add(nextPageEvent());
                      },
                    child: Text( "${AppLocalizations.of(context)!.translate("confirm_continue")}",
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: KColors.primaryColor),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 5,
                        decoration: BoxDecoration(
                          color: KColors.primaryColor,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 140,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ],
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
