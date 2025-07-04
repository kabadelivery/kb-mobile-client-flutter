part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class getChatsEvent extends ChatEvent {
}
class getChatByIdEvent extends ChatEvent {
  final String chatId;
  getChatByIdEvent({required this.chatId});
}

class openChatEvent extends ChatEvent {
  final ChatConversationEntity chat;
  Delivery? delivery;
  openChatEvent({required this.chat, this.delivery});
}
class sendMessageEvent extends ChatEvent{
  final ChatMessageEntity message;
  final String deliveryRequestId;
  sendMessageEvent({required this.message,required this.deliveryRequestId});
}
class sendMessageLocalEvent extends ChatEvent{
  final ChatMessageEntity message;
  final String deliveryRequestId;
  sendMessageLocalEvent({required this.message,required this.deliveryRequestId});
}
class getMessagesEvent extends ChatEvent {
  final String conversationId;
  getMessagesEvent({required this.conversationId});
}
class createConversationEvent extends ChatEvent{
  final ChatConversationEntity chat;
  Delivery? delivery;
  createConversationEvent({required this.chat,this.delivery});
}
class markMessageAsReadEvent extends ChatEvent {
  final String messageId;
  final String conversationId;
  markMessageAsReadEvent({required this.messageId, required this.conversationId});
}
class closeChatEvent extends ChatEvent{

}