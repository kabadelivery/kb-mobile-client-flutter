import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity{
   ChatMessageModel({
     required String? id,
     required String? content,
     required String? kabaUserId,
     required String? adminId,
     required bool? isFromAdmin,
     required bool? isRead,
     required String? createdAt,
     required String? updatedAt,
     required String? conversationId,
     required String? deliveryRequestId,
   }):super(
    id: id,
    conversationId: conversationId,
    content: content,
    kabaUserId: kabaUserId,
    adminId: adminId,
    isFromAdmin: isFromAdmin,
    isRead: isRead,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deliveryRequestId: deliveryRequestId,
   );
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      content: json['content'],
      kabaUserId: json['kabaUserId'],
      adminId: json['adminId'],
      isFromAdmin: json['isFromAdmin'],
      isRead: json['isRead'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      conversationId: json['conversationId'],
      deliveryRequestId: json['deliveryRequestId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'kabaUserId': kabaUserId,
      'adminId': adminId,
      'isFromAdmin': isFromAdmin,
      'isRead': isRead,
      'createdAt': createdAt,
      'updateAt': updatedAt,
      'conversationId': conversationId,
      'deliveryRequestId': deliveryRequestId,
    };
  }
}