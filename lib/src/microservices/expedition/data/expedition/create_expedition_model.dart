import 'dart:io';

import 'package:KABA/src/microservices/expedition/data/expedition/package_model.dart';

class CreateExpedition{
  String? adresseOrigine;
  String? adresseDestination;
  String? telephoneOrigine;
  String? telephoneDestination;
  String?methodeCollecte;
  List<PackageModel>?colis;
  DateTime? dateCollecte;
  String? heureCollecte;
  CreateExpedition({
    this.adresseDestination,
    this.telephoneDestination,
    this.adresseOrigine,
    this.colis,
    this.methodeCollecte,
    this.telephoneOrigine,
    this.dateCollecte,
    this.heureCollecte,
  });

  factory CreateExpedition.fromJson(Map<String, dynamic> json) {
    return CreateExpedition(
      adresseOrigine: json['adresseOrigine'],
      adresseDestination: json['adresseDestination'],
      telephoneOrigine: json['telephoneOrigine'],
      telephoneDestination: json['telephoneDestination'],
      methodeCollecte: json['methodeCollecte'],
      colis: json['colis'],
      dateCollecte: json['dateCollecte'],
      heureCollecte: json['heureCollecte'],
    );
  }
  Map<String, dynamic> toJson() => {
    "adresseOrigine": adresseOrigine,
    "adresseDestination": adresseDestination,
    "telephoneOrigine": telephoneOrigine,
    "telephoneDestination": telephoneDestination,
    "methodeCollecte": methodeCollecte,
    "colis": colis,
    "dateCollecte": dateCollecte,
    "heureCollecte": heureCollecte,
  };
}