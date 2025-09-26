part of 'estimation_bloc.dart';

@immutable
sealed class EstimationState {}

class EstimationInitial extends EstimationState {}

class EstimationLoading extends EstimationState {}

class EstimationError extends EstimationState {
  final String message;
  EstimationError(this.message);
}

class WeightEntered extends EstimationState {
  final double weight;
  WeightEntered(this.weight);
}

class EstimationCalculated extends EstimationState {
  final LinePricingCalculateModel result;
  EstimationCalculated(this.result);
}
class DepartureTownChosen extends EstimationState {
  final String town;
  DepartureTownChosen(this.town);
}

class ArrivalTownChosen extends EstimationState {
  final String town;
  ArrivalTownChosen(this.town);
}
class getAvailableLinesState extends EstimationState {
  final List<LineModel> lines;
  getAvailableLinesState(this.lines);
}