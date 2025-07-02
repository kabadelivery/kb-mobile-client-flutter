import 'dart:convert';

import 'package:KABA/src/microservices/kaba_chine/Enums/TarifType.dart';
import 'package:KABA/src/microservices/kaba_chine/data/tarif/shipping_model.dart';
import 'package:KABA/src/microservices/kaba_chine/data/tarif/tarif_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';

abstract class ShippingRemoteDataSource {
  Future<List<TarifModel>> getShippingRates();
  Future<List<TarifModel>> getRatesForRoute(String from, String to);
}

class ShippingRemoteDataSourceImpl implements ShippingRemoteDataSource {
  final http.Client client;
  final DEFAULT_RATES =[
    TarifModel(
        id: 'air-default',
        mode: Tariftype.plane.value,
        price: 12000,
        unit: 'kg',
        duration: 21,
        route: ShippingModel(departure: 'GuangZhou', destination: "Lomé"),
        updatedAt: new DateTime.now().toString()
    ),
    TarifModel(
        id: 'sea-default',
        mode: Tariftype.boat.value,
        price: 23000,
        unit: 'CBM',
        duration: 45,
        route: ShippingModel(departure: 'GuangZhou', destination: "Lomé"),
        updatedAt: new DateTime.now().toString()
    )
  ];
  ShippingRemoteDataSourceImpl(this.client);

  @override
  Future<List<TarifModel>> getShippingRates() async {
    final url = Uri.parse('$LINK_GET_TARIF');
    try {
      final response = await client.get(url);

      if (response.statusCode != 200) {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }

      final rawText = response.body;
      List<dynamic> jsonList;
      try {
        jsonList = json.decode(rawText);
      } catch (e) {
        throw Exception('Erreur de parsing JSON');
      }

      if (jsonList is! List) {
        throw Exception('Format de réponse invalide: attendu un tableau');
      }

      List<TarifModel> activeRates =[];

      for(var json in jsonList){
        TarifModel tarif =TarifModel(
            id: json['id'],
            mode: json['shippingMode']=="AVION"?Tariftype.plane.value:Tariftype.boat.value,
            price: double.parse(json['pricePerKg'].toString()),
            duration: json['shippingMode']== 'AVION' ? 21 : 45,
            unit: json['shippingMode']== 'AVION' ? 'kg' : 'CBM',
            route: ShippingModel(departure: 'GuangZhou', destination: "Lomé"),
            updatedAt: json['updatedAt'].toString()
        );
        activeRates.add(tarif);
      }
      debugPrintStack();
      debugPrint("Active Rates ${activeRates.toString()}");
      return activeRates;
    } catch (error) {
      print('Erreur lors de la récupération des tarifs: $error');
      return DEFAULT_RATES;
    }
  }

  @override
  Future<List<TarifModel>> getRatesForRoute(String from, String to) async {
    try {
      final allRates = await getShippingRates();
      return allRates.where((r) => r.route!.departure == from && r.route!.destination == to).toList();
    } catch (e) {
      print('Erreur lors de la récupération des tarifs pour $from → $to: $e');
      return DEFAULT_RATES.where(
            (r) => r.route!.departure == from && r.route!.destination == to,
      ).toList();
    }
  }
}
