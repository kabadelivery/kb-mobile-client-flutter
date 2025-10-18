class MessageModel {
  String type;          // "source" or "destination"
  String message;       // text message OR image URL
  String messageType;   // "text", "image", or "link"
  String senderName;    // name or pseudo of sender
  DateTime time;        // message timestamp

  MessageModel({
    required this.message,
    required this.type,
    this.messageType = "text",
    required this.senderName,
    required this.time,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      message: json['message'],
      type: json['type'],
      messageType: json['messageType'] ?? 'text',
      senderName: json['senderName'] ?? 'Unknown',
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type,
      'messageType': messageType,
      'senderName': senderName,
      'time': time.toIso8601String(),
    };
  }
}
