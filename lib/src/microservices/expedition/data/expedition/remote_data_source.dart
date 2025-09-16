import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/microservices/expedition/core/constants.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/expedition_model.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/line_model.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../utils/_static_data/ServerConfig.dart';
import 'create_expedition_model.dart';
import 'line_pricing_calculate_model.dart';
import 'negociation_model.dart';
import 'package:mime/mime.dart';
abstract class ExpeditionRemoteDataSource {
  Future<List<LineModel>> getShippingLines({required String customer_token});
  Future<LinePricingCalculateModel> calculateShippingLinePricing({
    required Map<String, dynamic> queryParameters,
    required String customer_token,
  });

  Future<ExpeditionModel> createAnExpedition({
    required CreateExpedition expedition,
    required CustomerModel customer,
  });
  Future<List<ExpeditionModel>> getUserExpedition({
    required String customer_token,
  });

  Future<NegotiationModel> createNegociation({
    required Map<String, dynamic> body,
    required String customer_token,
  });
  Future<String> uploadImage(String imagePath);
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
      debugPrint("XXX ${lines}");
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
      final response = await dio.get(GET_SINGLE_SHIPPING_LINE_PRICING_LINK+"ligneId=${queryParameters['ligneId']}&poids=${queryParameters['poids']}");
      final data = response.data;
      return LinePricingCalculateModel.fromJson(Map<String, dynamic>.from(data));
    } on DioError catch (e) {
      throw Exception('Erreur calculateShippingLinePricing: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue calculateShippingLinePricing: $e');
    }
  }
  @override
  Future<String> uploadImage(String imagePath) async {
    final uploadUrl =UPLOAD_IMAGE;

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.headers['Content-Type'] = 'multipart/form-data';

    final mimeType = lookupMimeType(imagePath);
    final file = await http.MultipartFile.fromPath(
      'file',
      imagePath,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
    debugPrint('Fichier image : ${file.filename}, ${file.length}');

    request.files.add(file);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 ||response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['url'] != null) {
        debugPrint('URL de l’image : ${data['url']}');
        return data['url'];
      } else {
        throw Exception('L’URL de l’image est absente de la réponse');
      }
    } else {
      throw Exception('Erreur lors de l’upload d’image : ${response.statusCode}');
    }
  }
 @override
 Future<ExpeditionModel> createAnExpedition({
   required CreateExpedition expedition,
   required CustomerModel customer,
 }) async {
   final dio = _dioWithToken(customer.token!);
   expedition.colis = expedition.colis?.map((colis) {
     colis.quantite=1;
     return colis;
   }).toList();
  var data ={
    "ligneId":expedition.colis![0].ligneId,
    "adresseOrigine": expedition.adresseOrigine,
    "adresseDestination": expedition.adresseDestination,
    "contactOrigine": expedition.telephoneOrigine,
    "telephoneOrigine": expedition.telephoneOrigine,
    "contactDestination":expedition.colis![0].recipientPhoneNumber,
    "telephoneDestination": expedition.colis![0].recipientPhoneNumber,
    "methodeLivraison":"International",
    "methodeCollecte": expedition.methodeCollecte,
    "colis": expedition.colis?.map((colis) {
      return colis.toJson();
    }).toList(),
    "dateCollecte": expedition.dateCollecte,
    "heureCollecte": expedition.heureCollecte,
    "createdBy": {
      "id":customer.phone_number,
      "email": customer.email,
      "password": "kaba_h0rnqu5edj",
      "name": customer.phone_number,
      "role": "CLIENT",
      "createdAt": DateTime.now().toString(),
      "updatedAt": DateTime.now().toString()
    },
  };

   var response = await dio.post(
     CREATE_EXPEDITION_LINK,
     data: data,
     options: Options(
       headers: {
         "Authorization": "Bearer ${customer.token}",
         "Content-Type": "application/json",
       },
     ),
   );
   if (response.statusCode == 200 || response.statusCode == 201) {
     final data = response.data;
     debugPrint("XXX ${data['colis']}");
     return ExpeditionModel.fromJson(Map<String, dynamic>.from(data));
   } else {
     throw Exception("❌ Failed to create expedition: ${response.data}");
   }
 }


  @override
  Future<List<ExpeditionModel>> getUserExpedition({
    required String customer_token,
  }) async {
    final dio = _dioWithToken(customer_token);

    try {
      final String url = GET_USER_EXPEDITION_LINK;
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
