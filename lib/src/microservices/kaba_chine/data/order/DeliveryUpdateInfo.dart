class DeliveryUpdateInfo {
  final String trackingCode;
  final String packageName;
  final String recipientName;

  DeliveryUpdateInfo({
    required this.trackingCode,
    required this.packageName,
    required this.recipientName,
  });

  factory DeliveryUpdateInfo.fromJson(Map<String, dynamic> json) {
    return DeliveryUpdateInfo(
      trackingCode: json['trackingCode'],
      packageName: json['packageName'],
      recipientName: json['recipientName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingCode': trackingCode,
      'packageName': packageName,
      'recipientName': recipientName,
    };
  }
}