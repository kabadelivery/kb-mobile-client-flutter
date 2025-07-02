import 'package:KABA/src/microservices/kaba_chine/data/tarif/tarif_model.dart';

import '../../data/tarif/data_remote_source.dart';

abstract class ShippingRepository {
  Future<List<TarifModel>> getShippingRates();
  Future<List<TarifModel>> getRatesForRoute(String from, String to);
}
class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemoteDataSource remoteDataSource;

  ShippingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TarifModel>> getShippingRates() {
    return remoteDataSource.getShippingRates();
  }

  @override
  Future<List<TarifModel>> getRatesForRoute(String from, String to) {
    return remoteDataSource.getRatesForRoute(from, to);
  }
}
