part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}
class getChatsState extends ChatState {
  final List<ChatConversationEntity> chats;
  final bool error;
  getChatsState({required this.chats, required this.error});
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
  bool sent;
  sendMessageState({required this.sent});
}
class sendMessageLocalState extends ChatState{
  final ChatMessageEntity message;
  sendMessageLocalState({required this.message});
}

class createConversationState extends ChatState{
  final ChatConversationEntity chat;
  Delivery?delivery;
  final bool error;
  createConversationState({required this.chat, required this.error, this.delivery});
}
class closeChatState extends ChatState{

}
class getMessagesState extends ChatState{
  final List<ChatMessageEntity> messages;
  final bool error;
  getMessagesState({required this.messages, required this.error});
}