import 'package:KABA/src/microservices/kaba_chine/data/chat/chat_conversation_model.dart';

import '../../data/chat/chat_message_model.dart';
import '../../data/chat/data_remote_source.dart';
import 'chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages({required String conversationId, int? limit, int? offset});
  Future<ChatMessageEntity?> sendMessage({required ChatMessageEntity message});
  Future<bool> markMessagesAsRead({required String conversationId, required bool isAdmin});
  Future<bool> deleteConversation({required String conversationId});
  Future<List<ChatConversationModel>> getConversations(String userId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Future<List<ChatMessageEntity>> getMessages({required String conversationId, int? limit, int? offset}) async {
    final models = await remote.getMessages(conversationId: conversationId, limit: limit, offset: offset);
    return models;
  }
  @override
  Future<List<ChatConversationModel>> getConversations(String userId) async {

    return await remote.getConversations(userId);
  }
  @override
  Future<ChatMessageEntity?> sendMessage({required ChatMessageEntity message}) async {

    final model =ChatMessageModel(
        id: message.id,
        content: message.content,
        kabaUserId: message.kabaUserId,
        adminId: message.adminId,
        isFromAdmin: message.isFromAdmin,
        isRead: message.isRead,
        createdAt: message.createdAt,
        updatedAt: message.updatedAt,
        conversationId: message.conversationId,
        deliveryRequestId: message.deliveryRequestId);
    final sent = await remote.sendMessage(model);
    return sent;
  }

  @override
  Future<bool> markMessagesAsRead({required String conversationId, required bool isAdmin}) {
    return remote.markMessagesAsRead(conversationId: conversationId, isAdmin: isAdmin);
  }

  @override
  Future<bool> deleteConversation({required String conversationId}) {
    return remote.deleteConversation(conversationId);
  }
}
