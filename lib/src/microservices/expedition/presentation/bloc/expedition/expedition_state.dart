part of 'expedition_bloc.dart';

@immutable
sealed class ExpeditionState {}

class ExpeditionInitial extends ExpeditionState {}

class ExpeditionLoading extends ExpeditionState {}

class ExpeditionError extends ExpeditionState {
  final String message;
  ExpeditionError(this.message);
}

class ShippingLinesLoaded extends ExpeditionState {
  final List<LineModel> lines;
  ShippingLinesLoaded(this.lines);
}

class LinePricingCalculated extends ExpeditionState {
  final LinePricingCalculateModel pricing;
  LinePricingCalculated(this.pricing);
}

class ExpeditionCreated extends ExpeditionState {
  final CreateExpedition expedition;
  ExpeditionCreated(this.expedition);
}

class UserExpeditionsLoaded extends ExpeditionState {
  final List<ExpeditionModel> expeditions;
  UserExpeditionsLoaded(this.expeditions);
}

class NegociationCreated extends ExpeditionState {
  final NegotiationModel negotiation;
  NegociationCreated(this.negotiation);
}

class PackagesUpdatedState extends ExpeditionState {
  final List<PackageModel> packages;
  final int packagesCount;
  int? index;

  PackagesUpdatedState({required this.packages, required this.packagesCount,  this.index});

  @override
  List<Object?> get props => [packages, packagesCount];
}

class ExpandPackageWidgetState extends ExpeditionState {
  final bool expanded;
  final int index;
  ExpandPackageWidgetState({required this.expanded, required this.index});
}
class DepartureTownChosenState extends ExpeditionState {
  final int packageIndex;
  final String town;
  DepartureTownChosenState({required this.packageIndex, required this.town});
}
class ArrivalTownChosenState extends ExpeditionState {
  final int packageIndex;
  final String town;
  ArrivalTownChosenState({required this.packageIndex, required this.town});
}

class WeightChangedState extends ExpeditionState {
  final int packageIndex;
  final double weight;
  WeightChangedState({required this.packageIndex, required this.weight});
}
class DescriptionChangedState extends ExpeditionState {
  final int packageIndex;
  final String description;
  DescriptionChangedState({required this.packageIndex, required this.description});
}
class RecipientAddressChangedState extends ExpeditionState {
  final int packageIndex;
  final String address;
  RecipientAddressChangedState({required this.packageIndex, required this.address});
}

class PhotoAddedState extends ExpeditionState {
  final int packageIndex;
  final int photoIndex;
  final File file;
  PhotoAddedState({
    required this.packageIndex,
    required this.photoIndex,
    required this.file,
  });
}

class EstimationPriceUpdatedState extends ExpeditionState {
  final int packageIndex;
  final int estimationPrice;
  EstimationPriceUpdatedState({
    required this.packageIndex,
    required this.estimationPrice,
  });
}
class AcceptedProhibitedItemsState extends ExpeditionState {
  final int packageIndex;
  final bool accepted;
  AcceptedProhibitedItemsState({
    required this.packageIndex,
    required this.accepted,
  });
}
class chooseShippingMethodState extends ExpeditionState{
  final String method;
  chooseShippingMethodState({required this.method});
}
class chooseShippingMethodAddressTypeState extends ExpeditionState{
  final String method;
  String? coords;
  chooseShippingMethodAddressTypeState({required this.method,this.coords});
}
class chooseFetchDateState extends ExpeditionState{
  final DateTime date;
  chooseFetchDateState({required this.date});
}
class chooseFetchTimeState extends ExpeditionState{
  final String hour;
  chooseFetchTimeState({required this.hour});
}

class enterSendPhoneNumberState extends ExpeditionState{
  final String phoneNumber;
  enterSendPhoneNumberState({required this.phoneNumber});
}