import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../../models/DeliveryRatingPending.dart';
import '../../utils/Enums/DeliveryRatingType.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc() : super(RatingInitial()) {
    on<RatingEvent>((event, emit) {
      if( event is RateDeliveryTypeEvent) {
        emit(RateDeliveryTypeState(
          deliveryRatingType: event.deliveryRatingType,
          rating: event.rating,
        ));
      }
      else if (event is GetTotalRatingEvent) {
        emit(GetTotalRatingState(totalRating: event.totalRating));
      }
      else if (event is sendDeliveryRatingPendingEvent) {
        emit(SendDeliveryRatingPendingState(deliveryRatingPending: event.deliveryRatingPending));
      }
      else if (event is nextPageEvent) {
        emit(NextPageState());
      }
      else if (event is previousPageEvent) {
        emit(PreviousPageState());
      }

    });
  }
}
