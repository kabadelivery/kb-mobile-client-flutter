import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/create_expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_pricing_calculate_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/negociation_model.dart';

import '../../../../models/CustomerModel.dart';
import '../../data/expedition/remote_data_source.dart';

abstract class ExpeditionRepository {
  Future<List<LineModel>> getShippingLines({required String customerToken});
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customerToken,
  });
  Future<ExpeditionModel> createAnExpedition({
    required CreateExpedition expedition,
    required CustomerModel customer,
  });
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,
      String delivery_id,String paymentMethod);
  Future<List<ExpeditionModel>> getUserExpedition({
    required String customerToken,
  });
  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customerToken,
  });
  Future<String> uploadImage(String imagePath);
}

class ExpeditionRepositoryImpl implements ExpeditionRepository {
  final ExpeditionRemoteDataSource remote;

  ExpeditionRepositoryImpl(this.remote);

  @override
  Future<List<LineModel>> getShippingLines({required String customerToken}) {
    return remote.getShippingLines(customer_token: customerToken);
  }

  @override
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,
      String delivery_id,String paymentMethod) {
    return remote.payForDelivery(customer, phoneNumber, amount, delivery_id,paymentMethod);
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
  Future<ExpeditionModel> createAnExpedition({
    required CreateExpedition expedition,
    required CustomerModel customer,
  }) {
    return remote.createAnExpedition(
      expedition: expedition,
      customer: customer,
    );
  }

  @override
  Future<List<ExpeditionModel>> getUserExpedition({
    required String customerToken,
  }) {
    return remote.getUserExpedition(customer_token: customerToken);
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
  @override
  Future<String> uploadImage(String imagePath) {
    return remote.uploadImage(imagePath);
  }
}
