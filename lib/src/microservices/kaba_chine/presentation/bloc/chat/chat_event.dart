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
  openChatEvent({required this.chat});
}
class sendMessageEvent extends ChatEvent{
  final ChatMessageEntity message;
  sendMessageEvent({required this.message});
}
class getMessagesEvent extends ChatEvent {
  final String conversationId;
  getMessagesEvent({required this.conversationId});
}