import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_conversation_entity.dart';

import '../../domain/chat/chat_message_entity.dart';
import 'chat_message_model.dart';

class ChatConversationModel extends ChatConversationEntity{
  ChatConversationModel({
    required String? id,
    required String? kabaUserId,
    required String? lastMessageAt,
    required String? createdAt,
    required String? updatedAt,
    required int? unreadAdminMessages,
    required int? unreadUserMessages,
    required List<ChatMessageEntity>? messages,
    required String? deliveryRequestId,
  }) : super(
          id: id,
          kabaUserId: kabaUserId,
          lastMessageAt: lastMessageAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
          unreadAdminMessages: unreadAdminMessages,
          unreadUserMessages: unreadUserMessages,
          messages: messages,
          deliveryRequestId: deliveryRequestId,
        );
  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'],
      kabaUserId: json['kabaUserId'],
      lastMessageAt: json['lastMessageAt'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      unreadAdminMessages: json['unreadAdminMessages'],
      unreadUserMessages: json['unreadUserMessages'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessageModel.fromJson(msg))
          .toList(),
      deliveryRequestId: json['deliveryRequestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kabaUserId': kabaUserId,
      'lastMessageAt': lastMessageAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'unreadAdminMessages': unreadAdminMessages,
      'unreadUserMessages': unreadUserMessages,
      'messages': messages?.map((msg) {
        ChatMessageModel msgModel=ChatMessageModel
          (id: msg.id,
            content:  msg.content,
            kabaUserId:  msg.kabaUserId,
            adminId:  msg.adminId,
            isFromAdmin:  msg.isFromAdmin,
            isRead:  msg.isRead,
            createdAt: createdAt,
            updatedAt: updatedAt,
            conversationId:  msg.conversationId,
            deliveryRequestId:  msg.deliveryRequestId);
        return    msgModel.toJson();
      }).toList(),
      'deliveryRequestId': deliveryRequestId,
    };
    }
}