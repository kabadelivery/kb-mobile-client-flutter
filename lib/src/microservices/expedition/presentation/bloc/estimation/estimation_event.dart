part of 'estimation_bloc.dart';

@immutable
sealed class EstimationEvent {}

class InitEstimationEvent extends EstimationEvent {}
class WeightChanged extends EstimationEvent {
  final double? weight;
  WeightChanged(this.weight);
}

class CalculateEstimation extends EstimationEvent {
  final String departureTown;
  final String arrivalTown;
  final double weight;
  final List<LineModel> availableLines;

  CalculateEstimation({
    required this.departureTown,
    required this.arrivalTown,
    required this.weight,
    required this.availableLines,
  });
}

class ChooseDepartureTown extends EstimationEvent {
  final String town;
  ChooseDepartureTown(this.town);
}

class ChooseArrivalTown extends EstimationEvent {
  final String town;
  ChooseArrivalTown(this.town);
}

class getAvailableLines extends EstimationEvent{}