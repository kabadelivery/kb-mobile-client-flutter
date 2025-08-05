import 'dart:async';

import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:KABA/src/ui/customwidgets/MyLoadingProgressWidget.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/order/delivery_model.dart';
import '../../domain/chat/chat_conversation_entity.dart';
import '../../functions/getRandomDecoys.dart';
import '../../functions/tests.dart';
import '../widgets/chatPopUp.dart';
import 'chat_conversation.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
class AllChatPage extends StatefulWidget {
  const AllChatPage({super.key});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  List<ChatConversationEntity> chatList = [];
  bool isLoading = true;

  bool showChat = false;
  late Delivery currentDelivery;
  late ChatConversationEntity currentChat;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatBloc>(context).add(getChatsEvent());
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      BlocProvider.of<ChatBloc>(context).add(getChatsEvent());
      debugPrint("XXX timer");
    });
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
          chatList = state.chats;
        }else if(state is openChatState){
          currentChat = state.chat;
          showChat = true;
          isLoading = false;
         if(state.delivery!=null)
            currentDelivery=state.delivery!;
         else {
           currentDelivery = Delivery(
               id: "",
               packageName: "",
               trackingCode: "",
               declaredValue: 0,
               recipientName: "",
               buyerPhoneNumber: "",
               shippingMode: 0,
               status: "PENDING",
               homeDelivery: false,
               estimatedWeight: 0,
               collectionOffice: "",
               destinationOffice: "",
               createdAt: DateTime.now(),
               updatedAt: DateTime.now()
           );

         }

        }else if(state is createConversationState){
          if(state.error){
            CherryToast.error(
              title: Text("${AppLocalizations.of(context)!.translate('error')}"),
              description: Text("${AppLocalizations.of(context)!.translate('error_creating_discussion')}"),
              toastPosition: Position.center,
            ).show(context);
          }else{
            CherryToast.success(
              title: Text("${AppLocalizations.of(context)!.translate('success')}"),
              description: Text("${AppLocalizations.of(context)!.translate('discussion_created_success')}"),
              toastPosition: Position.center,
            ).show(context);
            BlocProvider.of<ChatBloc>(context).add(openChatEvent(chat: state.chat,delivery: state.delivery));
          }
        }
        else if(state is closeChatState){
          showChat = false;
          isLoading = false;
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
              Text("${AppLocalizations.of(context)!.translate('discussions')}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: size.width,
                height: chatList.isNotEmpty ? size.height * 0.7 : 50,
                child: ListView.builder(
                  itemCount: chatList.length == 0 ? 1 : chatList.length,
                  itemBuilder: (context, index) {
                    if (chatList.isEmpty) {
                      return Center(
                        child: Text(
                          "${AppLocalizations.of(context)!.translate('no_discussion_with_kaba')}",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border:Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))
                      ),
                      child: MaterialButton(
                        onPressed: (){
                          BlocProvider.of<ChatBloc>(context).add(openChatEvent(chat: chatList[index]));
                        },

                        padding: EdgeInsets.all(10),
                        elevation: 0,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                    radius:size.width>360?  30:20,
                                    backgroundColor: KabaChineColors.primary,
                                    child: Icon(Icons.chat, color: Colors.white)
                                ),
                                SizedBox(width: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${AppLocalizations.of(context)!.translate('chat_with_kaba')}"+" ID-${chatList[index].id.toString().substring(0,size.width>360? 9:5)}...",
                                      style: TextStyle(fontSize: size.width>360? 16:12),),
                                    SizedBox(height: 5,),
                                    Text("${chatList[index].messages!.last.isFromAdmin! ? "${AppLocalizations.of(context)!.translate('admin')}" : "${AppLocalizations.of(context)!.translate('you')}"} : "
                                        "${chatList[index].messages!.last.content.toString().length>30?chatList[index].messages!.last.content.toString().substring(0,size.width >360?30:15)+"...":chatList[index].messages!.last.content}",
                                      style: TextStyle(color: Colors.grey,fontSize: 12),)
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${chatList[index].messages!.last!.updatedAt!.substring(0, 10)} ${chatList[index].messages!.last!.updatedAt!.substring(11, 16)}",
                                  style: TextStyle(color:     chatList[index].unreadAdminMessages!  > 0 ?KabaChineColors.success:Colors.grey, fontSize: 12),),
                                chatList[index].unreadUserMessages! > 0 ?
                                Container(
                                  height:20,
                                  width: 20,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: KabaChineColors.success,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    chatList[index].unreadUserMessages!.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ) : SizedBox.shrink()
                              ],
                            )
                          ],
                        )
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                child: MaterialButton(
                  onPressed: ()async {
                    startChatPopUp(context: context);
                  },

                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                  child: Center(
                    child: Text(
                      "${AppLocalizations.of(context)!.translate('start_new_discussion')}",
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
