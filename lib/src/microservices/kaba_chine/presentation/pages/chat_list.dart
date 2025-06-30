import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/order/delivery_model.dart';
import '../../domain/chat/chat_conversation_entity.dart';
import '../../functions/getRandomDecoys.dart';
import '../widgets/chatPopUp.dart';
import 'chat_conversation.dart';

class AllChatPage extends StatefulWidget {
  const AllChatPage({super.key});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  List<ChatConversationEntity> chatList = [];
  List<Delivery> deliveryHistory = [];
  bool isLoading = true;

  bool showChat = false;
  late Delivery currentDelivery;
  late ChatConversationEntity currentChat;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context).add(getChatsEvent());
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if(state is getChatsState){
          isLoading = false;
          deliveryHistory = state.deliveries;
          chatList = state.chats;
        }else if(state is openChatState){
          currentChat = state.chat;
          showChat = true;
          isLoading = false;
          currentDelivery = deliveryHistory[0];
        }
      },
      builder: (context, state) {
        return isLoading?Center(
          child: MyLoadingProgressWidget(),
        ):
        showChat?
        ChatConversationPage(conversation: currentChat, delivery: currentDelivery,):
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width,
                height: chatList.isNotEmpty ? size.height * 0.7 : 50,
                child: ListView.builder(
                  itemCount: chatList.length == 0 ? 1 : chatList.length,
                  itemBuilder: (context, index) {
                    if (chatList.isEmpty) {
                      return Center(
                        child: Text(
                          "Vous n'avez pas encore de discussion avec KABA",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                    return MaterialButton(
                      onPressed: (){
                        BlocProvider.of<ChatBloc>(context).add(openChatEvent(chat: chatList[index]));
                      },
                      padding: EdgeInsets.all(10),
                      elevation: 1,
                      color: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Chat ${index + 1}',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                child: MaterialButton(
                  onPressed: () {
                    startChatPopUp(
                      context: context,
                      deliveries: deliveryHistory,
                    );
                  },

                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                  child: Center(
                    child: Text(
                      'Démarrer une nouvelle discussion',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
