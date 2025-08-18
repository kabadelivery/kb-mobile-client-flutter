part of 'rating_bloc.dart';

@immutable
sealed class RatingEvent {}
class RateDeliveryTypeEvent extends RatingEvent{
  final DeliveryRatingType deliveryRatingType;
  final int rating;

  RateDeliveryTypeEvent({required this.deliveryRatingType, required this.rating});
}
class GetTotalRatingEvent extends RatingEvent {
  final double totalRating;

  GetTotalRatingEvent({required this.totalRating});
}
class sendDeliveryRatingPendingEvent extends RatingEvent {
  final DeliveryRatingPending deliveryRatingPending;

  sendDeliveryRatingPendingEvent({required this.deliveryRatingPending});
}