class LinePricingCalculateModel {
  final double prixBase;
  final double prixParKg;
  final double poidsTotal;
  final double reductionAppliquee;
  final double pourcentageReduction;
  final double prixFinal;
  final int dureeJours;
  final PricingDetails details;

  LinePricingCalculateModel({
    required this.prixBase,
    required this.prixParKg,
    required this.poidsTotal,
    required this.reductionAppliquee,
    required this.pourcentageReduction,
    required this.prixFinal,
    required this.dureeJours,
    required this.details,
  });

  factory LinePricingCalculateModel.fromJson(Map<String, dynamic> json) {
    return LinePricingCalculateModel(
      prixBase: (json['prixBase'] as num).toDouble(),
      prixParKg: (json['prixParKg'] as num).toDouble(),
      poidsTotal: (json['poidsTotal'] as num).toDouble(),
      reductionAppliquee: (json['reductionAppliquee'] as num).toDouble(),
      pourcentageReduction: (json['pourcentageReduction'] as num).toDouble(),
      prixFinal: (json['prixFinal'] as num).toDouble(),
      dureeJours: json['dureeJours'],
      details: PricingDetails.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() => {
    'prixBase': prixBase,
    'prixParKg': prixParKg,
    'poidsTotal': poidsTotal,
    'reductionAppliquee': reductionAppliquee,
    'pourcentageReduction': pourcentageReduction,
    'prixFinal': prixFinal,
    'dureeJours': dureeJours,
    'details': details.toJson(),
  };
}

class PricingDetails {
  final String ligne;
  final String reduction;

  PricingDetails({
    required this.ligne,
    required this.reduction,
  });

  factory PricingDetails.fromJson(Map<String, dynamic> json) {
    return PricingDetails(
      ligne: json['ligne'],
      reduction: json['reduction'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ligne': ligne,
    'reduction': reduction,
  };
}
