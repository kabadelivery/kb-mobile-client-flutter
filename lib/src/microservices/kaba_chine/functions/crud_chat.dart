import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';

import '../Enums/messageType.dart';
import '../domain/chat/chat_conversation_entity.dart';

Future<ChatMessageEntity> sendMessage({required  String message,required ChatConversationEntity conversation})async {
  CustomerModel? kabaUser = await CustomerUtils.getCustomer();
  ChatMessageEntity messageEntity = ChatMessageEntity(
    id: (conversation.messages!.length+1).toString(),
    content: message,
    kabaUserId:kabaUser.id.toString(),
    conversationId: conversation.id,
    isFromAdmin: false,
    isRead: false,
    adminId: '',
    createdAt: DateTime.now().toString(),
    updatedAt: DateTime.now().toString(),
    deliveryRequestId: conversation.deliveryRequestId,
  );


  return messageEntity;
}

Future<ChatConversationEntity> createConversation({required MessageType type, String? deliveryRequestId})async {
  CustomerModel? kabaUser = await CustomerUtils.getCustomer();
  ChatConversationEntity conversation = ChatConversationEntity(
    id:"",
    kabaUserId: kabaUser.id.toString(),
    lastMessageAt: DateTime.now().toString(),
    createdAt: DateTime.now().toString(),
    updatedAt: DateTime.now().toString(),
    unreadAdminMessages: 0,
    unreadUserMessages: 0,
    messages: [
      ChatMessageEntity(
        id: '',
        content: type==MessageType.GENERAL?"Bonjour, j'ai besoin d'aide générale.":"Bonjour, j'ai besoin de mon colis",
        kabaUserId: kabaUser.id.toString(),
        conversationId: '',
        isFromAdmin: false,
      )
    ],
    deliveryRequestId: deliveryRequestId,
  );
  return conversation;
}