import 'package:KABA/src/models/DeliveryAddressModel.dart';

class PackageModel {
  String? id;
  String? expeditionId;
  String? description;
  double? poids;
  int? quantite;
  List<String?>? images;
  String? adresseDestination;
  String? departureTown;
  String? arrivalTown;
  DeliveryAddressModel? recipientAddress;
  String? recipientPhoneNumber;
  String? ligneId;

  PackageModel({
    this.id,
    this.expeditionId,
    this.description,
    this.poids,
    this.quantite,
    this.images,
    this.adresseDestination,
    this.departureTown,
    this.arrivalTown,
    this.recipientAddress,
    this.recipientPhoneNumber,
    this.ligneId,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] as String?,
      expeditionId: json['expeditionId'] as String?,
      description: json['description'] as String?,
      poids: (json['poids'] as num?)?.toDouble(),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>)['url'] as String?)
          .toList(),
      adresseDestination: json['adresseDestination'] as String?,
      departureTown: json['departureTown'] as String?,
      arrivalTown: json['arrivalTown'] as String?,
      recipientPhoneNumber: json['recipientPhoneNumber'] as String?,
      recipientAddress: json['recipientAddress'] != null
          ? DeliveryAddressModel.fromJson(
          json['recipientAddress'] as Map<String, dynamic>)
          : null,
      quantite: json['quantite'] as int?,
      ligneId: json['ligneId'] as String?,
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
    'recipientAddress': recipientAddress?.toJson(),
    'quantite': quantite,
    'ligneId': ligneId,
  };

  PackageModel copyWith({
    String? id,
    String? expeditionId,
    String? description,
    double? poids,
    int? quantite,
    List<String?>? images,
    String? adresseDestination,
    String? departureTown,
    String? arrivalTown,
    DeliveryAddressModel? recipientAddress,
    String? recipientPhoneNumber,
    String? ligneId,
  }) {
    return PackageModel(
      id: id ?? this.id,
      expeditionId: expeditionId ?? this.expeditionId,
      description: description ?? this.description,
      poids: poids ?? this.poids,
      quantite: quantite ?? this.quantite,
      images: images ?? this.images,
      adresseDestination: adresseDestination ?? this.adresseDestination,
      departureTown: departureTown ?? this.departureTown,
      arrivalTown: arrivalTown ?? this.arrivalTown,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientPhoneNumber: recipientPhoneNumber ?? this.recipientPhoneNumber,
      ligneId: ligneId ?? this.ligneId,
    );
  }
}
