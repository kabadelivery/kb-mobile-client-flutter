import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/models/CustomerModel.dart';
import 'package:KABA/src/utils/functions/CustomerUtils.dart';

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