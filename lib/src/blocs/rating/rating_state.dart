part of 'rating_bloc.dart';

@immutable
sealed class RatingState {}

class RatingInitial extends RatingState {}
class RateDeliveryTypeState extends RatingState {
  final DeliveryRatingType deliveryRatingType;
  final int rating;

  RateDeliveryTypeState({required this.deliveryRatingType, required this.rating});
}
class GetTotalRatingState extends RatingState {
  final double totalRating;

  GetTotalRatingState({required this.totalRating});
}
class SendDeliveryRatingPendingState extends RatingState {
  final DeliveryRatingPending deliveryRatingPending;

  SendDeliveryRatingPendingState({required this.deliveryRatingPending});
}
class NextPageState extends RatingState {}
class PreviousPageState extends RatingState {
  final DeliveryRatingPending deliveryRatingPending;
  PreviousPageState({required this.deliveryRatingPending});
}
class showMoreReviewState extends RatingState {
  final bool showMore;
  showMoreReviewState({required this.showMore});
}
class KeyboardVisibilityChangedState extends RatingState {
  final bool isOpen;
  KeyboardVisibilityChangedState({required this.isOpen});
}