import '../../data/tarif/tarif_model.dart';
import '../../domain/tarif/repository.dart';

class GetRatesForRoute {
  final ShippingRepository repository;

  GetRatesForRoute(this.repository);

  Future<List<TarifModel>> call(String from, String to) {
    return repository.getRatesForRoute(from, to);
  }
}