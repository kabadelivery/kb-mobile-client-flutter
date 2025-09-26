class CityModel {
  String? id;
   String? nom;
   String? paysId;
   Map<String,dynamic>? pays;
  CityModel({
     this.id,
     this.nom,
     this.paysId,
    this.pays
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      nom: json['nom'],
      paysId: json['paysId'],
      pays: json['pays']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'paysId': paysId,
    'pays':pays
  };
}
