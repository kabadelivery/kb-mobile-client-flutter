part of 'expedition_bloc.dart';

@immutable
sealed class ExpeditionEvent {}
class ExpeditionInitialEvent extends ExpeditionEvent {}
class GetShippingLinesEvent extends ExpeditionEvent {
  final String customerToken;
  GetShippingLinesEvent(this.customerToken);
}

class CalculateShippingLinePricingEvent extends ExpeditionEvent {
  final Map<String, dynamic> queryParameters;
  final String customerToken;
  CalculateShippingLinePricingEvent({
    required this.queryParameters,
    required this.customerToken,
  });
}

class CreateExpeditionEvent extends ExpeditionEvent {
  final Map<String, dynamic> body;
  final String customerToken;
  CreateExpeditionEvent({
    required this.body,
    required this.customerToken,
  });
}

class GetUserExpeditionEvent extends ExpeditionEvent {
  final String id;
  final String customerToken;
  GetUserExpeditionEvent({
    required this.id,
    required this.customerToken,
  });
}

class CreateNegociationEvent extends ExpeditionEvent {
  final Map<String, dynamic> body;
  final String customerToken;
  CreateNegociationEvent({
    required this.body,
    required this.customerToken,
  });
}
class AddPackageEvent extends ExpeditionEvent {
  final int count;
  AddPackageEvent({this.count = 1});
}

class RemovePackageEvent extends ExpeditionEvent {
  final int count;
  RemovePackageEvent({this.count = 1});
}
class ExpandPackageWidgetAction extends ExpeditionEvent {
  final bool expanded;
  final int index;
  ExpandPackageWidgetAction({required this.expanded, required this.index});
}


class ChooseDepartureTownEvent extends ExpeditionEvent {
  final int packageIndex;
  final String town;
  ChooseDepartureTownEvent({required this.packageIndex, required this.town});
}


class ChooseArrivalTownEvent extends ExpeditionEvent {
  final int packageIndex;
  final String town;
  ChooseArrivalTownEvent({required this.packageIndex, required this.town});
}

class ChangeWeightEvent extends ExpeditionEvent {
  final int packageIndex;
  final double weight;
  ChangeWeightEvent({required this.packageIndex, required this.weight});
}

class ChangeDescriptionEvent extends ExpeditionEvent {
  final int packageIndex;
  final String description;
  ChangeDescriptionEvent({required this.packageIndex, required this.description});
}

class ChangeRecipientAddressEvent extends ExpeditionEvent {
  final int packageIndex;
  final DeliveryAddressModel address;
  ChangeRecipientAddressEvent({required this.packageIndex, required this.address});
}
class ChangeRecipientStringAddressEvent extends ExpeditionEvent {
  final int packageIndex;
  final String address;
  ChangeRecipientStringAddressEvent({required this.packageIndex, required this.address});
}
class AddPhotoEvent extends ExpeditionEvent {
  final int packageIndex;
  final int photoIndex;
  final File file;
  AddPhotoEvent({required this.packageIndex, required this.photoIndex, required this.file});
}

class SetPackageCountEvent extends ExpeditionEvent {
  final int count;
  SetPackageCountEvent(this.count);
}

class getAvailableLines extends ExpeditionEvent{}

class chooseShippingMethod extends ExpeditionEvent{
  final String method;

  chooseShippingMethod({required this.method});
}
class chooseShippingMethodAddressType extends ExpeditionEvent{
  final String method;
  String? coords;
  chooseShippingMethodAddressType({required this.method,this.coords});
}
class chooseFetchDateEvent extends ExpeditionEvent{
  final DateTime date;
  chooseFetchDateEvent({required this.date});
}
class chooseFetchTimeEvent extends ExpeditionEvent{
  final String hour;
  chooseFetchTimeEvent({required this.hour});
}
class enterRecipientPhoneNumber extends ExpeditionEvent{
  final int packageIndex;
  final String phoneNumber;
  enterRecipientPhoneNumber({required this.packageIndex, required this.phoneNumber});
}
class enterSendPhoneNumber extends ExpeditionEvent{
  final String phoneNumber;
  enterSendPhoneNumber({required this.phoneNumber});

}