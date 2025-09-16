
import 'package:KABA/src/microservices/expedition/data/expedition/facturation.dart';
import 'package:KABA/src/microservices/expedition/data/expedition/package_model.dart';

import 'createdby_model.dart';
import 'line_model.dart';

class ExpeditionModel {
   String? id;
   String? trackingNumber;
   String? partnerId;
   String? status;
   String? ligneId;
   String? adresseOrigine;
   String? adresseDestination;
   String? contactOrigine;
   String? contactDestination;
   String? telephoneOrigine;
   String? telephoneDestination;
   String? methodeLivraison;
   String? methodeCollecte;
   DateTime? estimatedDelivery;
   DateTime? actualDelivery;
   String? currentLocation;
   DateTime? createdAt;
   DateTime? updatedAt;
   List<PackageModel>? colis;
   LineModel? ligne;
   CreatedByModel? createdBy;
   ColisDetail? colisDetail;
  ExpeditionModel({
     this.id,
     this.trackingNumber,
    this.partnerId,
     this.status,
     this.ligneId,
     this.adresseOrigine,
     this.adresseDestination,
     this.contactOrigine,
     this.contactDestination,
     this.telephoneOrigine,
     this.telephoneDestination,
     this.methodeLivraison,
     this.methodeCollecte,
    this.estimatedDelivery,
    this.actualDelivery,
    this.currentLocation,
     this.createdAt,
     this.updatedAt,
     this.colis,
     this.ligne,
     this.createdBy,
    this.colisDetail
  });

  factory ExpeditionModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionModel(
      id: json['id'],
      trackingNumber: json['trackingNumber'],
      partnerId: json['partnerId'],
      status: json['status'],
      ligneId: json['ligneId'],
      adresseOrigine: json['adresseOrigine'],
      adresseDestination: json['adresseDestination'],
      contactOrigine: json['contactOrigine'],
      contactDestination: json['contactDestination'],
      telephoneOrigine: json['telephoneOrigine'],
      telephoneDestination: json['telephoneDestination'],
      methodeLivraison: json['methodeLivraison'],
      methodeCollecte: json['methodeCollecte'],
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.tryParse(json['estimatedDelivery'])
          : null,
      actualDelivery: json['actualDelivery'] != null
          ? DateTime.tryParse(json['actualDelivery'])
          : null,
      currentLocation: json['currentLocation'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      colis: (json['colis'] as List)
          .map((e) => PackageModel.fromJson(e))
          .toList(),
      ligne: LineModel.fromJson(json['ligne']),
      createdBy: CreatedByModel.fromJson(json['createdBy']),
      colisDetail: ColisDetail.fromJson(json['colisDetail']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trackingNumber': trackingNumber,
    'partnerId': partnerId,
    'status': status,
    'ligneId': ligneId,
    'adresseOrigine': adresseOrigine,
    'adresseDestination': adresseDestination,
    'contactOrigine': contactOrigine,
    'contactDestination': contactDestination,
    'telephoneOrigine': telephoneOrigine,
    'telephoneDestination': telephoneDestination,
    'methodeLivraison': methodeLivraison,
    'methodeCollecte': methodeCollecte,
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'actualDelivery': actualDelivery?.toIso8601String(),
    'currentLocation': currentLocation,
    'createdAt': createdAt!.toIso8601String(),
    'updatedAt': updatedAt!.toIso8601String(),
    'colis': colis!.map((e) => e?.toJson()).toList(),
    'ligne': ligne!.toJson(),
    'createdBy': createdBy!.toJson(),
    'colisDetail': colisDetail!.toJson(),
  };
}