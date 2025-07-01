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
  sendMessageEvent({required this.message});
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