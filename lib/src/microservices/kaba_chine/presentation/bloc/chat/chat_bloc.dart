import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_conversation_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/usecases/chat/getMessage.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../../../models/CustomerModel.dart';
import '../../../../../utils/functions/CustomerUtils.dart';
import '../../../data/chat/data_remote_source.dart';
import '../../../data/order/data_remote_source.dart';
import '../../../data/order/delivery_model.dart';
import '../../../domain/chat/repository.dart';
import '../../../domain/order/repository.dart';
import '../../../functions/getRandomDecoys.dart';
import '../../../usecases/chat/getConversation.dart';
import '../../../usecases/chat/markMessageAsRead.dart';
import '../../../usecases/chat/sendMessage.dart';
import '../../../usecases/order/get_orders.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatEvent>((event, emit) async{
      if(event is getChatsEvent){
        List<ChatConversationEntity> chats = [];

        CustomerModel customer = await CustomerUtils.getCustomer();
        bool error = false;

        GetConversations getConversations = GetConversations(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
              chats= await getConversations.call(customer.id.toString());

        GetMessages getMessages = GetMessages(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        for(ChatConversationEntity chat in chats){
          List <ChatMessageEntity> messages = [];
          messages = await getMessages.call(conversationId: chat.id.toString());
          int index = chats.indexOf(chat);
          messages.sort((a, b) {
            final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
            return dateA.compareTo(dateB);
          });
          chats[index].messages = messages;
        }
        emit(getChatsState(chats: chats,error: false));
      }
      else if(event is getChatByIdEvent){

      }
      else if(event is openChatEvent){
        emit(openChatState(chat: event.chat,delivery: event.delivery));
      }
      else if (event is sendMessageLocalEvent){
        emit(sendMessageLocalState(message: event.message));
      }
      else if (event is sendMessageEvent){
        bool error= true;
        try{
          SendMessage sendMessage = SendMessage(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
          ChatMessageEntity? message = await sendMessage.call(event.message);
          debugPrint("XXX deliveryRequestId ${event.deliveryRequestId}");
          message!.deliveryRequestId = event.deliveryRequestId;
          error = false;
        }catch(e){
          debugPrint("XXX error ${e.toString()}");
        }
        emit(sendMessageState(sent: error));
      }
      else if(event is createConversationEvent){
        SendMessage createConversation = SendMessage(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        ChatMessageEntity? created = await createConversation.call(event.chat.messages![0]);
        if(created==null){
          emit(createConversationState(chat: event.chat, error: true,delivery: event.delivery));
        }else{
          event.chat.id = created.conversationId!;
          event.chat.messages = [created];
          emit(createConversationState(chat: event.chat, error: false, delivery: event.delivery));
        }
        }
      else if(event is markMessageAsReadEvent){
        MarkMessagesAsRead markMessageAsRead = MarkMessagesAsRead(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        debugPrint("XXX markMessageAsReadEvent ${event.conversationId}");
        await markMessageAsRead.call(conversationId: event.conversationId, isAdmin: false);

      }
      else if(event is closeChatEvent){
        emit(closeChatState());
      }
      else if(event is getMessagesEvent){
        GetMessages getMessages = GetMessages(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        List<ChatMessageEntity> messages = await getMessages.call(conversationId: event.conversationId);

        if(messages!=null){
          if(messages.isNotEmpty){
            messages.sort((a, b) {
              final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
              final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
              return dateA.compareTo(dateB);
            });
            emit(getMessagesState(messages: messages, error: false));
          }
        }
      }
    });
  }
}
