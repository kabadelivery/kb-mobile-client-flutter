import '../../data/tarif/tarif_model.dart';
import '../../domain/tarif/repository.dart';

class GetShippingRates {
  final ShippingRepository repository;

  GetShippingRates(this.repository);

  Future<List<TarifModel>> call() {
    return repository.getShippingRates();
  }
}