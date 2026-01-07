enum AddressType { gps, quartier }

class Address {
  AddressType type;
  double? lat;
  double? lng;
  String? quartier;
  String? details;

  Address({required this.type});

  Map<String, dynamic> toJson() => {
    "type": type.name,
    "lat": lat,
    "lng": lng,
    "quartier": quartier,
    "details": details,
  };
}
