import 'package:bloc/bloc.dart';
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
    });
  }
}
