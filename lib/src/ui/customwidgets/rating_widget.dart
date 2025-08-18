import 'package:KABA/src/blocs/rating/rating_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/Enums/DeliveryRatingType.dart';
import '../../utils/_static_data/KTheme.dart';

Widget RatingWidget({required  BuildContext context,required Widget ratingTextAndIcon,required DeliveryRatingType rate_id}){
  int selectedRating = 3;
  return BlocSelector<RatingBloc, RatingState, RatingState>(
  selector: (state) {
    return state;
  },
  builder: (context, state) {
    if(state is RateDeliveryTypeState) {
      if(state.deliveryRatingType == rate_id) {
        selectedRating = state.rating;
      }
    }
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5.0), width: MediaQuery.of(context).size.width*0.87,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ratingTextAndIcon,
        Container(
          width: rate_id==DeliveryRatingType.ratingAricle?MediaQuery.of(context).size.width*.8: 150,
          height:rate_id==DeliveryRatingType.ratingAricle?80: 40,

          child: ListView.builder(
              itemExtent: 80,
              itemCount: 5,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context,index){
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            selectedRating = index + 1;
                            BlocProvider.of<RatingBloc>(context).add(
                              RateDeliveryTypeEvent(
                                deliveryRatingType: rate_id,
                                rating: selectedRating,
                              ),
                            );
                          },
                          child:Container(
                            width:  selectedRating==index+1 ?35:30,
                            height:  selectedRating==index+1 ?35:30,
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
                          )
                      ),
                      rate_id==DeliveryRatingType.ratingAricle?Container(
                        child:selectedRating ==( index+1) ?Text(
                            textAlign: TextAlign.center,
                          selectedRating==1 || selectedRating==2?"Médiocre":selectedRating==3?"Acceptable":selectedRating==4?"Satisfait":"Très satisfait",
                          style: TextStyle(fontSize: 13)
                        ):Container(),
                      ):Container()
                    ],
                  ),
                );
              }),
        ),
      ],
    ),
  );
  },
);
}