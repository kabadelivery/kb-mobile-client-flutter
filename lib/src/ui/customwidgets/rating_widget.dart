import 'package:KABA/src/blocs/rating/rating_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../localizations/AppLocalizations.dart';
import '../../utils/Enums/DeliveryRatingType.dart';
import '../../utils/_static_data/KTheme.dart';


class RatingWidget extends StatefulWidget {
  final Widget ratingTextAndIcon;
  final DeliveryRatingType rate_id;
  final int rate;
  RatingWidget({
    required  this.ratingTextAndIcon,
    required this.rate_id,
    required this.rate,
    super.key});

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int selectedRating = 3;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.rate;
  }
  @override
  Widget build(BuildContext context) {
    return BlocSelector<RatingBloc, RatingState, RatingState>(
      selector: (state) {
        return state;
      },
      builder: (context, state) {
        if(state is RateDeliveryTypeState) {
          if(state.deliveryRatingType == widget.rate_id) {
            selectedRating = state.rating;
          }
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5.0),
          width: MediaQuery.of(context).size.width*0.89,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  height:widget.rate_id==DeliveryRatingType.ratingAricle?0: 40,
                  width:widget.rate_id==DeliveryRatingType.ratingAricle?0:130,child: widget.ratingTextAndIcon
              ),
              Stack(
                children: [
                  widget.rate_id==DeliveryRatingType.ratingAricle?
                  Positioned(
                    left: 10,
                    top: 8,
                    child: Container(
                      width:230 ,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1.5,color: Colors.grey.withOpacity(0.5))
                      ),
                    ),
                  ):Container(),
                  Container(
                    width: widget.rate_id==DeliveryRatingType.ratingAricle?265: 170,
                    height:widget.rate_id==DeliveryRatingType.ratingAricle?80: 40,
                    alignment: Alignment.center,
                    child: ListView.builder(
                        itemCount: 5,
                        scrollDirection: Axis.horizontal,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context,index){
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      selectedRating = index + 1;
                                      BlocProvider.of<RatingBloc>(context).add(
                                        RateDeliveryTypeEvent(
                                          deliveryRatingType: widget.rate_id,
                                          rating: selectedRating,
                                        ),
                                      );
                                    },
                                    child:Row(
                                      children: [
                                        Container(
                                       
                                          width:  selectedRating==index+1 ?25:20,
                                          height:  selectedRating==index+1 ?25:20,
                                          decoration: BoxDecoration(
                                            color: selectedRating==index+1 ? KColors.primaryColor : Colors.white,
                                            shape: BoxShape.circle,
                                            border:  selectedRating==index+1 ?null:Border.all(
                                              color: Colors.grey,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              (index + 1).toString(),
                                              style: TextStyle(fontSize: 16, color:Colors.white),
                                            ),
                                          ),
                                        ),
                                        widget.rate_id==DeliveryRatingType.ratingAricle?Container(
                                          width:20,
                                        ):Container()
                                      ],
                                    )
                                ),
                                widget.rate_id==DeliveryRatingType.ratingAricle?Container(
                                  child:selectedRating ==( index+1) ?Container(
                                    width:60,
                                    child: Text(

                                        textAlign: TextAlign.center,
                                        selectedRating==1 || selectedRating==2?"${AppLocalizations.of(context)!.translate("rating_poor")}":selectedRating==3?"${AppLocalizations.of(context)!.translate("rating_fair")}":selectedRating==4?"${AppLocalizations.of(context)!.translate("rating_good")}":"${AppLocalizations.of(context)!.translate("rating_excellent")}",
                                        style: TextStyle(fontSize: 13)
                                    ),
                                  ):Container(),
                                ):Container()
                              ],
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
