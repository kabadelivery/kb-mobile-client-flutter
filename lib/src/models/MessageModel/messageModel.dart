class MessageModel {
  String type;          // "source" or "destination"
  String message;       // text message OR image URL
  String messageType;

  var time;
   // "text" or "image"

  MessageModel({
    required this.message,
    required this.type,
    this.messageType = "text",// default = text message
  });
}