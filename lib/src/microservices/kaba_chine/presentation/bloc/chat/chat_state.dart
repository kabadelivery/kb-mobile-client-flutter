part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}
class getChatsState extends ChatState {
  final List<ChatConversationEntity> chats;
  final bool error;
  final List<Delivery> deliveries;
  getChatsState({required this.chats, required this.error, required this.deliveries});
}
class getChatByIdState extends ChatState {
  final ChatConversationEntity chat;
  getChatByIdState({required this.chat});
}


class openChatState extends ChatState {
  final ChatConversationEntity chat;
  Delivery?delivery;
  openChatState({required this.chat, this.delivery});
}
class sendMessageState extends ChatState{
  final ChatMessageEntity message;
  sendMessageState({required this.message});
}

class createConversationState extends ChatState{
  final ChatConversationEntity chat;
  Delivery?delivery;
  final bool error;
  createConversationState({required this.chat, required this.error, this.delivery});
}