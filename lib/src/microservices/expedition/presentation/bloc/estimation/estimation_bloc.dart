import 'package:KABA/src/microservices/expedition/data/expedition/remote_data_source.dart';
import 'package:KABA/src/microservices/expedition/usecases/get_shipping_lines.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../data/expedition/line_model.dart';
import '../../../data/expedition/line_pricing_calculate_model.dart';
import '../../../domain/expedition/repo.dart';
import '../../../usecases/calculate_shipping_pricing.dart';

part 'estimation_event.dart';
part 'estimation_state.dart';

class EstimationBloc extends Bloc<EstimationEvent, EstimationState> {


  EstimationBloc() : super(EstimationInitial()) {
    on<WeightChanged>(_onWeightChanged);
    on<CalculateEstimation>(_onCalculateEstimation);
    on<ChooseDepartureTown>(_onChooseDepartureTown);
    on<ChooseArrivalTown>(_onChooseArrivalTown);
    on<getAvailableLines>(_onGetAvailableLines);
  }

  void _onWeightChanged(WeightChanged event, Emitter<EstimationState> emit) {
    if (event.weight != null && event.weight! > 0) {
      emit(WeightEntered(event.weight!));
    } else {
      emit(EstimationInitial());
    }
  }
  Future<void> _onGetAvailableLines(
      getAvailableLines event,
      Emitter<EstimationState> emit,
      ) async {
    GetShippingLines lines = GetShippingLines(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
    CustomerModel customerModel = await CustomerUtils.getCustomer();
    List<LineModel> linesList = await lines.call(customerToken: customerModel.token!);
  }
  Future<void> _onCalculateEstimation(
      CalculateEstimation event,
      Emitter<EstimationState> emit,
      ) async {
    emit(EstimationLoading());

    try {
       final matchingLine = event.availableLines.firstWhere(
            (line) =>
        line.depart?.nom?.toLowerCase() == event.departureTown.toLowerCase() &&
            line.arrivee?.nom?.toLowerCase() == event.arrivalTown.toLowerCase(),
        orElse: () => throw Exception("Aucune ligne trouvée entre ${event.departureTown} et ${event.arrivalTown}"),
      );
       CustomerModel customerModel = await CustomerUtils.getCustomer();
       CalculateShippingLinePricing calculateUseCase = CalculateShippingLinePricing(ExpeditionRepositoryImpl(ExpeditionRemoteDataSourceImpl()));
      final result = await calculateUseCase(
        queryParameters: {
          "ligneId": matchingLine.id,
          "poids": event.weight,
        },
        customerToken: customerModel.token!,
      );
      emit(EstimationCalculated(result));
    } catch (e) {
      emit(EstimationError(e.toString()));
    }
  }
  void _onChooseDepartureTown(
      ChooseDepartureTown event,
      Emitter<EstimationState> emit,
      ) {
    emit(DepartureTownChosen(event.town));
  }

  void _onChooseArrivalTown(
      ChooseArrivalTown event,
      Emitter<EstimationState> emit,
      ) {
    emit(ArrivalTownChosen(event.town));
  }
}

