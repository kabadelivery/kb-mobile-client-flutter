import 'city_model.dart';

class LineModel {
   String? id;
   String? departId;
   String? arriveeId;
   bool? active;
   String? partenaireId;
   double? prixParKg;
   int? dureeJours;
   CityModel? depart;
   CityModel? arrivee;

  LineModel({
     this.id,
     this.departId,
     this.arriveeId,
     this.active,
     this.partenaireId,
     this.prixParKg,
     this.dureeJours,
     this.depart,
     this.arrivee,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      id: json['id'],
      departId: json['departId'],
      arriveeId: json['arriveeId'],
      active: json['active'],
      partenaireId: json['partenaireId'],
      prixParKg: (json['prixParKg'] as num).toDouble(),
      dureeJours: json['dureeJours'],
      depart: CityModel.fromJson(json['depart']),
      arrivee: CityModel.fromJson(json['arrivee']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'departId': departId,
    'arriveeId': arriveeId,
    'active': active,
    'partenaireId': partenaireId,
    'prixParKg': prixParKg,
    'dureeJours': dureeJours,
    'depart': depart!.toJson(),
    'arrivee': arrivee!.toJson(),
  };
}
