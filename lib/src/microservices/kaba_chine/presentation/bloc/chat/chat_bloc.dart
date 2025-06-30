import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_conversation_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/order/delivery_model.dart';
import '../../../functions/getRandomDecoys.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatEvent>((event, emit) async{
      if(event is getChatsEvent){

        // Simulate fetching chats from a repository
        List<ChatConversationEntity> chats = [
          ChatConversationEntity(
            id: '1',
            kabaUserId: 'user1',
            lastMessageAt: '2023-10-01T12:00:00Z',
            createdAt: '2023-10-01T11:00:00Z',
            updatedAt: '2023-10-01T12:00:00Z',
            unreadAdminMessages: 0,
            unreadUserMessages: 1,
            messages: [],
            deliveryRequestId: null,
          ),
          ChatConversationEntity(
            id: '2',
            kabaUserId: 'user2',
            lastMessageAt: '2023-10-02T12:00:00Z',
            createdAt: '2023-10-02T11:00:00Z',
            updatedAt: '2023-10-02T12:00:00Z',
            unreadAdminMessages: 2,
            unreadUserMessages: 0,
            messages: [],
            deliveryRequestId: null,
          ),
        ];

        List <Delivery> deliveries = [];
        await Future.delayed(Duration(seconds: 2));
        deliveries = [
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
          randomizedStatusDecoy(),
        ];

        emit(getChatsState(chats: chats,error: false,deliveries:deliveries));
      }
      else if(event is getChatByIdEvent){

      }
      else if(event is openChatEvent){
        emit(openChatState(chat: event.chat));
      }

      else if (event is sendMessageEvent){
        emit(sendMessageState(message: event.message));
      }
    });
  }
}
