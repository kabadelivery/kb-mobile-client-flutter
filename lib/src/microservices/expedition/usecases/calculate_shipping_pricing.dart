
import '../data/expedition/line_pricing_calculate_model.dart';
import '../domain/expedition/repo.dart';

class CalculateShippingLinePricing {
  final ExpeditionRepository repository;

  CalculateShippingLinePricing(this.repository);

  Future<LinePricingCalculateModel> call({
    required Map<String, dynamic> queryParameters,
    required String customerToken,
  }) {
    return repository.calculateShippingLinePricing(
      queryParameters: queryParameters,
      customerToken: customerToken,
    );
  }
}
