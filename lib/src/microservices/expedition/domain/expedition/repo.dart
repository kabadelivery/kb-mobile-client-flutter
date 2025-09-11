import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/create_expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_pricing_calculate_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/negociation_model.dart';

import '../../data/expedition/remote_data_source.dart';

abstract class ExpeditionRepository {
  Future<List<LineModel>> getShippingLines({required String customerToken});
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customerToken,
  });
  Future<CreateExpedition> createAnExpedition({
    required Map<String, dynamic> body,
    required String customerToken,
  });
  Future<List<ExpeditionModel>> getUserExpedition({
    required String id,
    required String customerToken,
  });
  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customerToken,
  });
}

class ExpeditionRepositoryImpl implements ExpeditionRepository {
  final ExpeditionRemoteDataSource remote;

  ExpeditionRepositoryImpl(this.remote);

  @override
  Future<List<LineModel>> getShippingLines({required String customerToken}) {
    return remote.getShippingLines(customer_token: customerToken);
  }

  @override
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customerToken,
  }) {
    return remote.calculateShippingLinePricing(
      queryParameters: queryParameters,
      customer_token: customerToken,
    );
  }

  @override
  Future<CreateExpedition> createAnExpedition({
    required Map<String, dynamic> body,
    required String customerToken,
  }) {
    return remote.createAnExpedition(
      body: body,
      customer_token: customerToken,
    );
  }

  @override
  Future<List<ExpeditionModel>> getUserExpedition({
    required String id,
    required String customerToken,
  }) {
    return remote.getUserExpedition(id: id, customer_token: customerToken);
  }

  @override
  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customerToken,
  }) {
    return remote.createNegociation(
      body: body,
      customer_token: customerToken,
    );
  }
}
