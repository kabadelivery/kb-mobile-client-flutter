import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import 'DeliveryStatusUpdate.dart';
import 'delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<Delivery> createDeliveryRequest(Delivery delivery);
  Future<String> uploadImage(String imagePath, {String type = 'proof'});
  Future<List<Delivery>> getDeliveryHistory(String userId);
  Future<List<DeliveryStatusUpdate>> checkForStatusUpdates(String userId);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final http.Client client;

  DeliveryRemoteDataSourceImpl(this.client);

  @override
  Future<Delivery> createDeliveryRequest(Delivery delivery) async {
    final uri = Uri.parse('$LINK_GET_DELIVERIES');
    Map<String, dynamic> deliveryRequest={
    "packageName": delivery.packageName!,
    "declaredValue": delivery.declaredValue,
    "trackingCode": delivery.trackingCode,
    "purchaseProofImage": delivery.purchaseProofImage,
    "productImage": delivery.productImage,
    "recipientName": delivery.recipientName,
    "buyerPhoneNumber": delivery.buyerPhoneNumber,
    "shippingMode": delivery.shippingMode,
    "homeDelivery": delivery.homeDelivery,
    "estimatedWeight": delivery.estimatedWeight,
    "collectionOffice": delivery.collectionOffice,
    "destinationOffice": delivery.destinationOffice,
    "addressId": string,
    "addressText": string,
    "notes": string,
    "kabaUserId": string,
    };
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(delivery.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Delivery.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur création demande : ${response.statusCode}');
    }
  }

  @override
  Future<String> uploadImage(String imagePath, {String type = 'proof'}) async {
    final uploadUrl = type == 'proof'
        ? '$LINK_UPLOAD_PROOF_IMAGE'
        : '$LINK_PRODUCT_IMAGE';

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    final file = await http.MultipartFile.fromPath('file', imagePath);
    request.files.add(file);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['url'] != null) {
        return data['url'];
      } else {
        throw Exception('L’URL de l’image est absente de la réponse');
      }
    } else {
      throw Exception('Erreur lors de l’upload d’image : ${response.statusCode}');
    }
  }

  @override
  Future<List<Delivery>> getDeliveryHistory(String userId) async {
    final uri = Uri.parse('$LINK_GET_DELIVERIES');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);

      final deliveries = jsonList
          .where((d) =>
      d['userId'] == userId ||
          d['buyerId'] == userId ||
          d['kabaUserId'] == userId)
          .map((d) {
        d['status'] = d['currentStatus'] ?? d['status'] ?? 'PENDING';
        return Delivery.fromJson(d);
      })
          .toList();

      return deliveries;
    } else {
      throw Exception('Erreur récupération historique : ${response.statusCode}');
    }
  }

  @override
  Future<List<DeliveryStatusUpdate>> checkForStatusUpdates(String userId) async {
    final uri = Uri.parse('$LINK_GET_DELIVERIES/updates/$userId');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((j) => DeliveryStatusUpdate.fromJson(j)).toList();
    } else {
      throw Exception('Erreur vérification statut : ${response.statusCode}');
    }
  }
}
