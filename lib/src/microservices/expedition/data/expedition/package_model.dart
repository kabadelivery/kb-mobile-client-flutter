import 'dart:io';

import 'package:KABA/src/models/DeliveryAddressModel.dart';

class PackageModel {
  String? id;
  String? expeditionId;
  String? description;
  double? poids;
  int? quantite;
  List<File?>? images;
  String? adresseDestination;
  String? departureTown;
  String? arrivalTown;
  DeliveryAddressModel? recipientAddress;
  String?  recipientPhoneNumber ;
  PackageModel({
    this.id,
    this.expeditionId,
    this.description,
    this.poids,
    this.images,
    this.adresseDestination,
    this.departureTown,
    this.arrivalTown,
    this.recipientAddress,
    this.recipientPhoneNumber
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      expeditionId: json['expeditionId'],
      description: json['description'],
      poids: (json['poids'] as num).toDouble(),
      images: List<File?>.from(json['images']),
      adresseDestination: json['adresseDestination'],
      departureTown: json['departureTown'],
      arrivalTown: json['arrivalTown'],
      recipientPhoneNumber: json['recipientPhoneNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'expeditionId': expeditionId,
    'description': description,
    'poids': poids,
    'images': images,
    'adresseDestination': adresseDestination,
    'departureTown': departureTown,
    'arrivalTown': arrivalTown,
    'recipientPhoneNumber': recipientPhoneNumber,
  };

  PackageModel copyWith({
    String? id,
    String? expeditionId,
    String? description,
    double? poids,
    int? quantite,
    List<File?>? images,
    String? adresseDestination,
    String? departureTown,
    String? arrivalTown,
    String? recipientPhoneNumber,
    DeliveryAddressModel? recipientAddress
  }) {
    return PackageModel(
      id: id ?? this.id,
      expeditionId: expeditionId ?? this.expeditionId,
      description: description ?? this.description,
      poids: poids ?? this.poids,
      images: images ?? this.images,
      adresseDestination: adresseDestination ?? this.adresseDestination,
      departureTown: departureTown ?? this.departureTown,
      arrivalTown: arrivalTown ?? this.arrivalTown,
      recipientPhoneNumber: recipientPhoneNumber ?? this.recipientPhoneNumber,
      recipientAddress: recipientAddress ?? this.recipientAddress,
    );
  }
}
