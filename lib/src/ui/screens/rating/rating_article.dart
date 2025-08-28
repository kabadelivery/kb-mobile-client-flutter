import 'package:KABA/src/models/CustomerModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../blocs/rating/rating_bloc.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/DeliveryRatingPending.dart';
import '../../../resources/order_api_provider.dart';
import '../../../utils/Enums/DeliveryRatingType.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../../utils/functions/Utils.dart';
import '../../../utils/functions/new_rating_feature.dart';
import '../../customwidgets/rating_widget.dart';
import '../home/buy/shop/flower/ShopFlowerDetailsPage.dart';

class RatingArticle extends StatefulWidget {
  final DeliveryRatingPending deliveryRatingPending;
  final bool canRateFood;
  final bool deleteAll;
  const RatingArticle({required this.deliveryRatingPending,required this.canRateFood, required this.deleteAll, super.key});

  @override
  State<RatingArticle> createState() => _RatingArticleState();
}

class _RatingArticleState extends State<RatingArticle> {
  String sellerName = "DaVodou";
  String sellerImage = "https://t3.ftcdn.net/jpg/01/97/11/64/360_F_197116416_hpfTtXSoJMvMqU99n6hGP4xX0ejYa4M7.jpg";
  String articleName = "";
  int totalRating = 3;
  TextEditingController commentController = TextEditingController();
  DeliveryRatingPending deliveryRatingPending= DeliveryRatingPending();
  @override
void initState() {
    super.initState();
    sellerImage = widget.deliveryRatingPending.seller_image!;
    sellerName = widget.deliveryRatingPending.seller_name!;
    articleName = widget.deliveryRatingPending.articles![0]['name']!;
    deliveryRatingPending = widget.deliveryRatingPending;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocSelector<RatingBloc, RatingState, RatingState>(
      selector: (state) {
        return state;
      },
  builder: (context, state) {
    if (state is RateDeliveryTypeState) {
      totalRating = state.rating;
    }
    if (state is SendDeliveryRatingPendingState) {
      deliveryRatingPending = state.deliveryRatingPending;
    }
    if (state is NextPageState) {
      commentController.text = deliveryRatingPending.article_comment!;
      totalRating = deliveryRatingPending.article_rating!.toInt();
    }
    return Container(
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
                        image: NetworkImage("https://app.kaba-delivery.com/resto_pic/$sellerImage")),
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
                        "${AppLocalizations.of(context)!.translate("merchant")}",
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: GestureDetector(
                      onTap: (){
                        deliveryRatingPending.article_comment = commentController.text;
                        deliveryRatingPending.article_rating = totalRating.toDouble();
                        BlocProvider.of<RatingBloc>(context).add(previousPageEvent(deliveryRatingPending: deliveryRatingPending));
                      },
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios, size: 15, color: Colors.black87),
                          Flexible(
                            child: Text(
                              "${AppLocalizations.of(context)!.translate("purchase_feedback")} $sellerName?",
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
                 widget.canRateFood? Column(
                    children: [
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
                      SizedBox(height: 10,),
                      RatingWidget(
                        rate: totalRating,
                        ratingTextAndIcon: Container(),
                        rate_id: DeliveryRatingType.ratingAricle,
                      ),

                    ],
                  ):Container(
                   height:  105,
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
                            hintStyle: TextStyle(color: Colors.black54, fontSize: 12),
                            hintText: "${AppLocalizations.of(context)!.translate("add_item_comment")}",
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
                  const SizedBox(height: 10),
                  deliveryRatingPending.articles!.length==1?  GestureDetector(
                    onTap: ()async{
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
                      debugPrint("Article Rating: ${deliveryRatingPending.toJson()}");
                      OrderApiProvider provider = OrderApiProvider();
                      CustomerModel customer =await CustomerUtils.getCustomer();
                      provider.sendFeedback(customer,deliveryRatingPending);
                      if(widget.deleteAll){
                        deleteRatePendingFromCache();
                      }else{
                        removeSingleRatePendingFromCache(deliveryRatingPending.command_id.toString());
                      }
                      Navigator.pop(context);
                      Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              ShopFlowerDetailsPage(food: widget.deliveryRatingPending.food),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var begin = Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end);
                            var curvedAnimation =
                            CurvedAnimation(parent: animation, curve: curve);
                            return SlideTransition(
                                position: tween.animate(curvedAnimation), child: child);
                          }));
                    },
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
                          Text( "${AppLocalizations.of(context)!.translate("reorder")}",
                            style: TextStyle(fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ):Container(
                    height: 40,
                  ),
                  const SizedBox(height: 10),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                     ),
                    onPressed: ()async{
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
                      debugPrint("Article Rating: ${deliveryRatingPending.toJson()}");
                      OrderApiProvider provider = OrderApiProvider();
                      CustomerModel customer =await CustomerUtils.getCustomer();
                      provider.sendFeedback(customer,deliveryRatingPending);
                      if(widget.deleteAll){
                        deleteRatePendingFromCache();
                      }else{
                        removeSingleRatePendingFromCache(deliveryRatingPending.command_id.toString());
                      }
                      Navigator.pop(context);
                    },
                    child: Text("${AppLocalizations.of(context)!.translate("back_to_shop_menu")}",
                      style: TextStyle(fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: KColors.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Container(
                        width: 140,
                        height: 5,
                        decoration: BoxDecoration(
                          color: KColors.primaryColor,
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
      );
  },
),
    );
  }
}
