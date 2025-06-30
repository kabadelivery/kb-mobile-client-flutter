part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}
class GetHistoryEvent extends HistoryEvent {
}
class GetHistoryByIdEvent extends HistoryEvent {
  final String deliveryId;
  GetHistoryByIdEvent({required this.deliveryId});
}

class PayForDeliveryEvent extends HistoryEvent {
  final Delivery delivery;
  PayForDeliveryEvent({required this.delivery});
}

class EndDeliveryPaymentEvent extends HistoryEvent {
  final String msg;
  final bool error;
  EndDeliveryPaymentEvent({required this.msg, required this.error});
}