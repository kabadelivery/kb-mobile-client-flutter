import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_conversation_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/usecases/chat/getMessage.dart';
import 'package:bloc/bloc.dart';
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
        List <Delivery> deliveries = [];
        CustomerModel customer = await CustomerUtils.getCustomer();
        bool error = false;
        GetDeliveryHistory getDeliveryHistory = GetDeliveryHistory(DeliveryRepositoryImpl(DeliveryRemoteDataSourceImpl(http.Client())));
        deliveries = await getDeliveryHistory.call(customer.id.toString());
        if(deliveries==null||deliveries.isEmpty) {
          error = true;
          deliveries = [];
        }


        if(chats==null){
          chats = [];
          error = true;
        }else{
          GetMessages getMessages = GetMessages(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
          for (var chat in chats) {
            if(chat.messages==null||chat.messages!.isEmpty){
              chat.messages = [];
            }else{
              chat.messages = await getMessages.call(conversationId: chat.id!);
            }
          }
        }
        emit(getChatsState(chats: chats,error: false,deliveries:deliveries));
      }
      else if(event is getChatByIdEvent){

      }
      else if(event is openChatEvent){
        emit(openChatState(chat: event.chat,delivery: event.delivery));
      }
      else if (event is sendMessageEvent){
        SendMessage sendMessage = SendMessage(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        await sendMessage.call(event.message);
        emit(sendMessageState(message: event.message));
      }
      else if(event is createConversationEvent){
        SendMessage createConversation = SendMessage(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        ChatMessageEntity message = await createConversation.call(event.chat.messages![0]);
        if(message==null){
          emit(createConversationState(chat: event.chat, error: true,delivery: event.delivery));
        }else{
          event.chat.messages!.removeLast();
          event.chat.messages!.add(message);
          emit(createConversationState(chat: event.chat, error: false,delivery: event.delivery));
        }
        }
      else if(event is markMessageAsReadEvent){
        MarkMessagesAsRead markMessageAsRead = MarkMessagesAsRead(ChatRepositoryImpl(ChatRemoteDataSourceImpl(http.Client())));
        await markMessageAsRead.call(conversationId: event.conversationId, isAdmin: false);

      }
    });
  }
}
