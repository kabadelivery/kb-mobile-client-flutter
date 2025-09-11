import 'package:KABA/src/microservices/expedition/core/constants.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_model.dart';
import 'package:dio/dio.dart';

import '../../../../utils/_static_data/ServerConfig.dart';
import 'create_expedition_model.dart';
import 'line_pricing_calculate_model.dart';
import 'negociation_model.dart';

abstract class ExpeditionRemoteDataSource {
  Future<List<LineModel>> getShippingLines({required String customer_token});
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customer_token,
  });

  Future<CreateExpedition> createAnExpedition({
    required Map<String, dynamic> body,
    required String customer_token,
  });
  Future<List<ExpeditionModel>> getUserExpedition({
    required String id,
    required String customer_token,
  });

  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customer_token,
  });
}

class ExpeditionRemoteDataSourceImpl extends ExpeditionRemoteDataSource {
  Dio _dioWithToken(String token) {
    return Dio(BaseOptions(
      baseUrl: ServerConfig.kaba_expedition,
      connectTimeout: 5000,
      receiveTimeout: 10000,
      headers: {
        "Authorization": token,
        "Content-Type": "application/json",
      },
    ));
  }

  @override
  Future<List<LineModel>> getShippingLines({required String customer_token}) async {
    final dio = _dioWithToken(customer_token);

    try {
      final response = await dio.get(GET_SHIPPING_LINES_LINK);
      final data = response.data;

      final List<LineModel> lines = [];

      if (data is List) {
        for (var e in data) {
          lines.add(LineModel.fromJson(Map<String, dynamic>.from(e)));
        }
      } else if (data is Map && data['data'] is List) {
        for (var e in data['data']) {
          lines.add(LineModel.fromJson(Map<String, dynamic>.from(e)));
        }
      } else if (data is Map) {
        lines.add(LineModel.fromJson(Map<String, dynamic>.from(data)));
      }

      return lines;
    } on DioError catch (e) {
      throw Exception('Erreur getShippingLines: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue getShippingLines: $e');
    }
  }

  @override
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customer_token,
  }) async {
    final dio = _dioWithToken(customer_token);

    try {
      final response = await dio.get(GET_SHIPPING_LINES_PRICING_LINK, queryParameters: queryParameters);
      final data = response.data;
      return LinePricingCalculateModel.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (e) {
      throw Exception('Erreur calculateShippingLinePricing: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue calculateShippingLinePricing: $e');
    }
  }

  @override
  Future<CreateExpedition> createAnExpedition({
    required Map<String, dynamic> body,
    required String customer_token,
  }) async {
    final dio = _dioWithToken(customer_token);

    try {
      final response = await dio.post(CREATE_EXPEDITION_LINK, data: body);
      final data = response.data;
      return CreateExpedition.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (e) {
      // si API renvoie un message d'erreur dans response.data, tu peux le récupérer ici
      final message = e.response?.data ?? e.message;
      throw Exception('Erreur createAnExpedition: $message');
    } catch (e) {
      throw Exception('Erreur inattendue createAnExpedition: $e');
    }
  }

  @override
  Future<List<ExpeditionModel>> getUserExpedition({
    required String id,
    required String customer_token,
  }) async {
    final dio = _dioWithToken(customer_token);

    try {
      final String url = (id.toLowerCase() == 'me') ? GET_USER_EXPEDITION_LINK : '${ServerConfig.kaba_expedition}/expeditions/$id';
      final response = await dio.get(url);
      final data = response.data;

      final List<ExpeditionModel> result = [];
      if (data is List) {
        for (var e in data) {
          result.add(ExpeditionModel.fromJson(Map<String, dynamic>.from(e)));
        }
      } else if (data is Map && data['data'] is List) {
        for (var e in data['data']) {
          result.add(ExpeditionModel.fromJson(Map<String, dynamic>.from(e)));
        }
      } else if (data is Map) {
        result.add(ExpeditionModel.fromJson(Map<String, dynamic>.from(data)));
      }

      return result;
    } on DioError catch (e) {
      throw Exception('Erreur getUserExpedition: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue getUserExpedition: $e');
    }
  }

  @override
  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customer_token,
  }) async {
    final dio = _dioWithToken(customer_token);

    try {
      final response = await dio.post(CREATE_A_NEGOTIATION_LINK, data: body);
      final data = response.data;
      return NegotiationModel.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Erreur createNegociation: $message');
    } catch (e) {
      throw Exception('Erreur inattendue createNegociation: $e');
    }
  }
}
