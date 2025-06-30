
import 'chat_message_entity.dart';

class ChatConversationEntity {
  String? id;
  String? kabaUserId;
  String? lastMessageAt;
  String? createdAt;
  String? updatedAt;
  int? unreadAdminMessages;
  int? unreadUserMessages;
  List<ChatMessageEntity>? messages;
  String? deliveryRequestId;

  ChatConversationEntity({
    this.id,
    this.kabaUserId,
    this.lastMessageAt,
    this.createdAt,
    this.updatedAt,
    this.unreadAdminMessages,
    this.unreadUserMessages,
    this.messages,
    this.deliveryRequestId,
  });

}