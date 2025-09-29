class NegotiationModel {
  final String expeditionId;
  final double montantPropose;
  final String raison;

  NegotiationModel({
    required this.expeditionId,
    required this.montantPropose,
    required this.raison,
  });

  factory NegotiationModel.fromJson(Map<String, dynamic> json) {
    return NegotiationModel(
      expeditionId: json['expeditionId'],
      montantPropose: (json['montantPropose'] as num).toDouble(),
      raison: json['raison'],
    );
  }

  Map<String, dynamic> toJson() => {
    'expeditionId': expeditionId,
    'montantPropose': montantPropose,
    'raison': raison,
  };
}
