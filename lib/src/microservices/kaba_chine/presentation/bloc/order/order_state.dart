part of 'order_bloc.dart';

@immutable
sealed class OrderState {}

final class OrderInitial extends OrderState {}
class getInfosState extends OrderState {
  UserEntity user;
  getInfosState({required this.user});
}
class chooseExpeditionModeState extends OrderState {
  final Tariftype expeditionMode;
  chooseExpeditionModeState({required this.expeditionMode});
}
class switchDeliveryModeState extends OrderState {
  final bool isHomeDelivery;
  switchDeliveryModeState({required this.isHomeDelivery});
}
class chooseProofImageState extends OrderState {
  final File proofImage;
  chooseProofImageState({required this.proofImage});
}
class chooseProductImageState extends OrderState {
  final File productImage;
  chooseProductImageState({required this.productImage});
}
class enterPackageNameState extends OrderState {
  final String packageName;
  enterPackageNameState({required this.packageName});
}
class enterPackageWeightState extends OrderState {
  final double packageWeight;
  enterPackageWeightState({required this.packageWeight});
}
class enterPackagePriceState extends OrderState {
  final double packagePrice;
  enterPackagePriceState({required this.packagePrice});
}
class enterRecipientNameState extends OrderState {
  final String recipientName;
  enterRecipientNameState({required this.recipientName});
}
class enterRecipientPhoneState extends OrderState {
  final String recipientPhone;
  enterRecipientPhoneState({required this.recipientPhone});
}
class enterAdditionnalNotesState extends OrderState {
  final String additionnalNotes;
  enterAdditionnalNotesState({required this.additionnalNotes});
}
class checkPackageIsSafeState extends OrderState {
  final bool packageCondition;
  checkPackageIsSafeState({required this.packageCondition});
}
class checkGeneralConditionState extends OrderState {
  final bool generalCondition;
  checkGeneralConditionState({required this.generalCondition});
}
class LoadingState extends OrderState{}
class startOrderingState extends OrderState {
  final Delivery delivery;
  startOrderingState({required this.delivery});
}
class endOrderingState extends OrderState {
  bool error;
  final String msg;
  endOrderingState({required this.msg,required this.error});
}