import 'package:KABA/src/models/CustomerModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../blocs/rating/rating_bloc.dart';
import '../../../localizations/AppLocalizations.dart';
import '../../../models/DeliveryRatingPending.dart';
import '../../../models/ShopProductModel.dart';
import '../../../resources/order_api_provider.dart';
import '../../../utils/Enums/DeliveryRatingType.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../../utils/functions/Utils.dart';
import '../../../utils/functions/new_rating_feature.dart';
import '../../customwidgets/rating_widget.dart';
import '../home/buy/shop/flower/ShopFlowerDetailsPage.dart';

class RatingReview extends StatefulWidget {
  final ShopProductModel food;
  const RatingReview({required this.food, super.key});
  @override
  State<RatingReview> createState() => _RatingReviewState();
}

class _RatingReviewState extends State<RatingReview> {
  @override
  void initState() {
    super.initState();
  }
  bool showMore = false;
  @override
  Widget build(BuildContext context) {
    print(" widget.food.food_review_array ${ widget.food.food_review_array![0]}");
    return Scaffold(
      body: BlocSelector<RatingBloc, RatingState, RatingState>(
        selector: (state) {
          return state;
        },
        builder: (context, state) {
          if (state is showMoreReviewState) {
          }
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                // Background header
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                    color: KColors.primaryColor,
                    borderRadius:  BorderRadius.circular(30)
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 40) ,
                          SizedBox(width: 10,),
                          Row(
                            children: [
                              Text("Note : ",style: TextStyle(color: Colors.white,fontSize: 25),),
                              Text('${widget.food.rating.toString().substring(2,3)=="0"?
                              widget.food.rating.toString().substring(0,1):widget.food.rating!.toStringAsFixed(1)}/5',
                                style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.info_outline,color: Colors.white,),
                          SizedBox(width: 10,),
                          Text("Ceci est la note moyenne de l'article",style: TextStyle(color: Colors.white),)
                        ],
                      )

                    ],
                  ),
                ),

                // Moved this out of Container and into Stack
                Positioned(
                  top: 80,
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
                            image: CachedNetworkImageProvider(
                                Utils.inflateLink(widget.food!.pic!))
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
                  top: MediaQuery.of(context).size.height * 0.30,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        widget.food.name!,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 12, color: Colors.black87),

                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.food.review_count==1?"Une":widget.food.review_count}",
                            style: const TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 16, color: Colors.black87),

                          ),
                          Text('${widget.food.review_count==1?" personne a noté":" personnes ont notés"} cet article'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        alignment: Alignment.center,

                        width: 350,
                        height: 180,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child:   ListView.builder(
                            itemCount: widget.food.review_count,
                            itemBuilder: (context, index) {
                              Map review = widget.food.food_review_array![index];
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: KColors.primaryColor.withOpacity(0.1),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: "https://kaba-delivery-pictures-store.s3.eu-west-3.amazonaws.com/profile_pic/${review['client_picture']}",
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                          placeholder: (context, url) => const Icon(Icons.person,color:  KColors.primaryColor, size: 30),
                                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 30,color:  KColors.primaryColor,),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "@${review['client_name']} ",
                                              style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,
                                              fontFamily: "Inter",fontSize: 12

                                              ),
                                            ),
                                            Text(
                                              "à noté ",
                                              style: TextStyle(color: Colors.black54),

                                            ),
                                            Text("${review['rating']}/5",
                                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black87)),
                                          ],
                                        ),

                                        Container(
                                          width:240,
                                          child: Text(
                                            maxLines: 10,
                                           review['comment'],  style: TextStyle(color: Colors.black54,fontSize: 12),),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                              elevation: 0,
                            padding: EdgeInsets.only(right: 10.0,left: 2.0),
                            color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1,color: KColors.primaryColor),
                            borderRadius: BorderRadius.circular(50),

                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.arrow_circle_left_outlined,color: KColors.primaryColor,size: 30,),
                              Text("Retour au menu",style: TextStyle(color: KColors.primaryColor,fontSize: 12),)
                            ],
                          ),
                          onPressed: (){
                                Navigator.pop(context);
                          }
                          ),
                          SizedBox(width: 10,),
                          MaterialButton(
                             elevation: 0,
                              padding: EdgeInsets.only(right: 10.0,left: 10.0),
                              color: KColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),

                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.shopping_cart_checkout,color: Colors.white,size: 20,),
                                  Text("Ajouter au panier",style: TextStyle(color:Colors.white,fontSize: 12),)
                                ],
                              ),
                              onPressed: (){
                               Navigator.of(context).pop({'add_to_basket':true});
                              }
                          ),

                        ],
                      )
                    ],
                  ),
                ),
               /*
               *  Positioned(
                  bottom: 60,
                  right: 20,
                  child:
                 Container(
                   padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Voir plus",style: TextStyle(color: Colors.white),),
                      Icon(Icons.add_circle_outlined,color: Colors.white,)
                    ],
                  ),
                ))*/
              ],
            ),
          );
        },
      ),
    );
  }
}

