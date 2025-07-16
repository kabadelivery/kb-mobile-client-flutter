import 'dart:convert';
import 'dart:io';

import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/payment_info_model.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/payment_model.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../models/CustomerModel.dart';
import '../../../../utils/_static_data/ServerRoutes.dart';
import '../../../../utils/functions/Utils.dart';
import '../../../../utils/ssl/ssl_validation_certificate.dart';
import '../../core/constants.dart';
import '../../domain/order/status_history_entry.dart';
import 'DeliveryStatusUpdate.dart';
import 'delivery_model.dart';

abstract class DeliveryRemoteDataSource {
  Future<Delivery> createDeliveryRequest(Delivery delivery);
  Future<String> uploadImage(String imagePath, {String type = 'proof'});
  Future<List<Delivery>> getDeliveryHistory(String userId);
  Future<List<DeliveryStatusUpdate>> checkForStatusUpdates(String userId);
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,
      String delivery_id,String paymentMethod);
}

class DeliveryRemoteDataSourceImpl implements DeliveryRemoteDataSource {
  final http.Client client;

  DeliveryRemoteDataSourceImpl(this.client);

  @override
  Future<Delivery> createDeliveryRequest(Delivery delivery) async {
    final uri = Uri.parse('$LINK_GET_DELIVERIES');

    Map<String, dynamic> deliveryRequest = {
      "kabaUserId": delivery.kabaUserId.toString(),
      "packageName": delivery.packageName!.toString(),
      "trackingCode": delivery.trackingCode.toString(),
      "declaredValue": delivery.declaredValue,
      "purchaseProofImage": delivery.purchaseProofImage.toString(),
      "productImage": delivery.productImage.toString(),
      "recipientName": delivery.recipientName.toString(),
      "buyerPhoneNumber": delivery.buyerPhoneNumber.toString(),
      "shippingMode": delivery.shippingMode==Tariftype.boat.value?"BATEAU":"AVION",
      "homeDelivery": delivery.homeDelivery,
      "estimatedWeight": delivery.estimatedWeight,
      "collectionOffice": delivery.collectionOffice.toString(),
      "destinationOffice": delivery.destinationOffice.toString(),
      "addressText": delivery.addressText.toString(),
      "notes": delivery.notes.toString(),
    };
    debugPrint(deliveryRequest.toString());
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(deliveryRequest),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map <String, dynamic> jsonResponse = json.decode(response.body);
      return Delivery(
          id: jsonResponse['id']??"",
          packageName: jsonResponse['packageName']??"",
          trackingCode: jsonResponse['trackingCode']??"",
          declaredValue: double.parse(jsonResponse['declaredValue'].toString())??0.0,
          recipientName: jsonResponse['recipientName']??"",
          buyerPhoneNumber: jsonResponse['buyerPhoneNumber']??"",
          shippingMode: jsonResponse['shippingMode']=="AVION"?Tariftype.plane.value:Tariftype.boat.value,
          status: jsonResponse['status']??"PENDING",
          homeDelivery: jsonResponse['homeDelivery']??false,
          estimatedWeight: double.parse(jsonResponse['estimatedWeight'].toString()),
          collectionOffice: jsonResponse['collectionOffice']??"",
          destinationOffice: jsonResponse['destinationOffice']??"",
          createdAt:DateTime.parse(jsonResponse['createdAt']??""),
          purchaseProofImage: jsonResponse['purchaseProofImage']??"",
          productImage: jsonResponse['productImage']??"",
          notes: jsonResponse['notes']??"",
          updatedAt: DateTime.parse(jsonResponse['updatedAt']??""),
          userId: jsonResponse['kabaUserId']??"",
          kabaUserId: jsonResponse['kabaUserId']??"",
          buyerId: jsonResponse['kabaUserId']??"",
          afalikaBatchId: jsonResponse['afalikaBatchId']??"",
          afalikaTrackingId: jsonResponse['afalikaTrackingId']??"",
          afalikaPackageId: jsonResponse['afalikaPackageId']??"",
          afalikaTrackingCode: jsonResponse['afalikaTrackingCode']??"",
          address: jsonResponse['address']??"",
          estimatedArrival: jsonResponse['estimatedArrival'] != null
              ? DateTime.parse(jsonResponse['estimatedArrival'])
              : null,
          statusHistory: jsonResponse['statusHistory'] != null
              ? (jsonResponse['statusHistory'] as List)
                  .map((e) => StatusHistoryEntry(
                    id: e['id']??"",
                    deliveryRequestId: e['deliveryRequestId']??"",
                    status: e['status'].toString(),
                    createdAt: e['createdAt']??"",
                    location: e['location']??"",
                    notes: e['notes']??"",
                    performedBy: e['performedBy']??"",
                   ))
                  .toList()
              : null,

      );
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
  Future<List<Delivery>> getDeliveryHistory(String userId) async {
    final uri = Uri.parse('$LINK_GET_DELIVERIES');
    final response = await client.get(uri);

    if (response.statusCode == 200 || response.statusCode==201) {
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
      final userPayement = await client.get(Uri.parse('$LINK_GET_USER_PAYMENTS/$userId'));
      if (userPayement.statusCode == 200 || userPayement.statusCode==201) {
         if(userPayement.body.isNotEmpty || userPayement.body!=""){
           final List<PaymentModel> paymentList =jsonList.map((item)=>PaymentModel.fromJson(json.decode(userPayement.body))).toList();
           for (final delivery in deliveries) {
             for(PaymentModel payment in paymentList){
               if(delivery.id == payment.deliveryRequestId){
                 delivery.payments!.add(payment);
               }
             }
           }
         }
        }
      else{
          throw Exception('Error getting payments : ${userPayement.statusCode}');
      }

      final paymentInfo = await client.get(Uri.parse('$LINK_GET_DELIVERY_PAYMENT_INFOS'));
      if (paymentInfo.statusCode == 200 || paymentInfo.statusCode==201) {
        if(paymentInfo.body.isNotEmpty || paymentInfo.body!=""){
          PaymentInfoModel paymentInfoModel = PaymentInfoModel.fromJson(json.decode(paymentInfo.body));

        }
      }else{
        throw Exception('Erreur fetching payment infos : ${paymentInfo.statusCode}');
      }
      return deliveries;
    } else {
      throw Exception('Erreur fetching history of delivery: ${response.statusCode}');
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

  @override
  Future<Map> payForDelivery(CustomerModel customer, String phoneNumber, String amount,String delivery_id,paymentMethod) async {
    debugPrint("entered launchTopUp");
    if (await Utils.hasNetwork()) {
      var dio = Dio();
      dio.options
        ..headers = Utils.getHeadersWithToken(customer.token!)
        ..connectTimeout = 10000;
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return validateSSL(cert, host, port);
        };
      };
      var response = await dio.post(
        LINK_INIT_PAYMENT,
        data: json.encode(
            {
              "deliveryRequestId": delivery_id,
              "kabaUserId": customer.id,
              "amount": amount,
              "paymentMethod": paymentMethod,
              "currency": "FCFA",
              "phoneNumber": phoneNumber
            }
        ),
        );

      debugPrint(response.data.toString());
      if (response.statusCode == 200) {
        int errorCode = mJsonDecode(response.data)["error"];
        if (errorCode == 0) {
          return response.data;
        } else
          throw Exception(-1); // there is an error in your request
      } else {
        throw Exception(response.statusCode); // you have no right to do this
      }
    } else {
      throw Exception(-2); // you have no network
    }
  }
}
