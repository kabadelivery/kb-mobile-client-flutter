import "dart:convert";
class Facturation {
  final String id;
  final String expeditionId;
  final int montant;
  final FacturationDetails details;
  final DateTime createdAt;
  final DateTime updatedAt;

  Facturation({
    required this.id,
    required this.expeditionId,
    required this.montant,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Facturation.fromJson(Map<String, dynamic> json) {
    return Facturation(
      id: json['id'] as String,
      expeditionId: json['expeditionId'] as String,
      montant: json['montant'] as int,
      details: FacturationDetails.fromJson(
        // `details` est une string JSON, on la décode
        Map<String, dynamic>.from(
          jsonDecode(json['details'] as String),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expeditionId': expeditionId,
      'montant': montant,
      'details': jsonEncode(details.toJson()), // on ré-encode en String
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FacturationDetails {
  final String mode;
  final List<ColisDetail> colis;
  final int total;
  final DateTime calculeLe;

  FacturationDetails({
    required this.mode,
    required this.colis,
    required this.total,
    required this.calculeLe,
  });

  factory FacturationDetails.fromJson(Map<String, dynamic> json) {
    return FacturationDetails(
      mode: json['mode'] as String,
      colis: (json['colis'] as List)
          .map((c) => ColisDetail.fromJson(c as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      calculeLe: DateTime.parse(json['calculeLe'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode,
      'colis': colis.map((c) => c.toJson()).toList(),
      'total': total,
      'calculeLe': calculeLe.toIso8601String(),
    };
  }
}
class ColisDetail {
  final String description;
  final double poids;
  final String ligneId;
  final int prixParKg;
  final int prixBase;
  final int reductionAppliquee;
  final int pourcentageReduction;
  final int prixFinal;

  ColisDetail({
    required this.description,
    required this.poids,
    required this.ligneId,
    required this.prixParKg,
    required this.prixBase,
    required this.reductionAppliquee,
    required this.pourcentageReduction,
    required this.prixFinal,
  });

  factory ColisDetail.fromJson(Map<String, dynamic> json) {
    return ColisDetail(
      description: json['description'] as String,
      poids: (json['poids'] as num).toDouble(),
      ligneId: json['ligneId'] as String,
      prixParKg: json['prixParKg'] as int,
      prixBase: json['prixBase'] as int,
      reductionAppliquee: json['reductionAppliquee'] as int,
      pourcentageReduction: json['pourcentageReduction'] as int,
      prixFinal: json['prixFinal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'poids': poids,
      'ligneId': ligneId,
      'prixParKg': prixParKg,
      'prixBase': prixBase,
      'reductionAppliquee': reductionAppliquee,
      'pourcentageReduction': pourcentageReduction,
      'prixFinal': prixFinal,
    };
  }
}