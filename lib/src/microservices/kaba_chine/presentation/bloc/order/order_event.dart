part of 'order_bloc.dart';

@immutable
sealed class OrderEvent {}

class getInfosEvent extends OrderEvent {}
class chooseExpeditionModeEvent extends OrderEvent {
  final Tariftype expeditionMode;
  chooseExpeditionModeEvent({required this.expeditionMode});
}
class switchDeliveryModeEvent extends OrderEvent {
  final bool isHomeDelivery;
  switchDeliveryModeEvent({required this.isHomeDelivery});
}
class chooseProofImageEvent extends OrderEvent {
  final File proofImage;
  chooseProofImageEvent({required this.proofImage});
}
class chooseProductImageEvent extends OrderEvent {
  final File productImage;
  chooseProductImageEvent({required this.productImage});
}
class enterPackageNameEvent extends OrderEvent {
  final String packageName;
  enterPackageNameEvent({required this.packageName});
}
class enterPackageWeightEvent extends OrderEvent {
  final double packageWeight;
  enterPackageWeightEvent({required this.packageWeight});
}
class enterPackagePriceEvent extends OrderEvent {
  final double packagePrice;
  enterPackagePriceEvent({required this.packagePrice});
}
class enterRecipientNameEvent extends OrderEvent {
  final String recipientName;
  enterRecipientNameEvent({required this.recipientName});
}
class enterRecipientPhoneEvent extends OrderEvent {
  final String recipientPhone;
  enterRecipientPhoneEvent({required this.recipientPhone});
}
class enterAdditionnalNotesEvent extends OrderEvent {
  final String additionnalNotes;
  enterAdditionnalNotesEvent({required this.additionnalNotes});
}
class checkPackageIsSafeEvent extends OrderEvent {
  final bool packageCondition;
  checkPackageIsSafeEvent({required this.packageCondition});
}
class checkGeneralConditionEvent extends OrderEvent {
  final bool generalCondition;
  checkGeneralConditionEvent({required this.generalCondition});
}
class LoadingEvent extends OrderEvent {
}
class startOrderingEvent extends OrderEvent {
  final Delivery delivery;
  startOrderingEvent({required this.delivery});
}
class OrderingIsOverEvent extends OrderEvent {
  final String msg;
  OrderingIsOverEvent({required this.msg});
}
class enterPackageCodeEvent extends OrderEvent {
  final String packageCode;
  enterPackageCodeEvent({required this.packageCode});
}