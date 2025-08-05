import 'dart:async';

import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/chat/chat_message_model.dart';
import '../../domain/chat/chat_conversation_entity.dart';
import '../../functions/crud_chat.dart';
import 'delivery_details.dart';
import 'package:KABA/src/localizations/AppLocalizations.dart';
class ChatConversationPage extends StatefulWidget {
  final ChatConversationEntity conversation;
  final Delivery delivery;
  const ChatConversationPage({super.key, required this.conversation, required this.delivery});

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  TextEditingController messageController = TextEditingController();
  ChatConversationEntity conversation=ChatConversationEntity();
  ScrollController _scrollController = ScrollController();
  late Delivery delivery;
  late Timer _timer;
  @override
  void initState() {
    conversation = widget.conversation;
    delivery= widget.delivery;
    conversation.messages!.sort((a, b) {
      final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(1970);
      return dateA.compareTo(dateB);
    });
    if(conversation.messages!.isNotEmpty){
      if(conversation.messages!.last.isRead!){
        BlocProvider.of<ChatBloc>(context).add(markMessageAsReadEvent(conversationId: conversation.id.toString(), messageId: conversation.messages!.last.id.toString()));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });
    BlocProvider.of<ChatBloc>(context).add(getMessagesEvent(conversationId: conversation.id!));
    _timer = Timer.periodic(Duration(seconds: 15), (timer) {
      BlocProvider.of<ChatBloc>(context).add(getMessagesEvent(conversationId: conversation.id!));
      debugPrint("XXX timer");
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {

      if(state is sendMessageLocalState){
        conversation.messages!.add(
            ChatMessageModel(
              id: state.message.id,
              content: state.message.content,
              isFromAdmin: state.message.isFromAdmin,
              kabaUserId: state.message.kabaUserId,
              adminId: state.message.adminId,
              conversationId: state.message.conversationId,
              deliveryRequestId: state.message.deliveryRequestId,
              createdAt: state.message.createdAt,
              updatedAt: state.message.updatedAt,
              isRead: state.message.isRead,
            )
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
        BlocProvider.of<ChatBloc>(context).add(sendMessageEvent(message: state.message,deliveryRequestId: widget.delivery.id.toString()));

      }
      else if (state is sendMessageState){

      }
      else if(state is getMessagesState){
        conversation.messages = state.messages;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
        for(int i=0;i<conversation.messages!.length;i++){
          if(conversation.messages![i].isRead==false){
            BlocProvider.of<ChatBloc>(context).add(markMessageAsReadEvent(conversationId: conversation.id.toString(), messageId: conversation.messages![i].id.toString()));
          }
        }

      }
        },
        builder: (context, state) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Container(
              padding: EdgeInsets.all(20),
               width:size.width,
              alignment: Alignment.bottomCenter,
              height: 100,
              color: KabaChineColors.primary,
              child: MaterialButton(
                padding: EdgeInsets.all(0),
                elevation: 0,
                color: Colors.transparent,
                minWidth: size.width,
                shape:RoundedRectangleBorder(),
                onPressed: () {
                  BlocProvider.of<ChatBloc>(context).add(closeChatEvent());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    Text("${AppLocalizations.of(context)!.translate('back_to_chats')}",style: TextStyle(color: Colors.white,fontSize: 16),),
                    Container()
                  ],
                ),
              )),
          SizedBox(height: 20),
       widget.delivery.userId!=null  ?Container(

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PackageDeliveryDetailsWidget(
                            delivery:widget.delivery,
                          ),
                        ),
                      );
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color(0x22a4ddff),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${AppLocalizations.of(context)!.translate('discussion_about_delivery')}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text("${AppLocalizations.of(context)!.translate('view_delivery')}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                              ],
                            ),
                          ],
                        )
                    ),
                  )
                ],
              ),
            ),
          ):Container(),
          Container(
            width: size.width,
            height:widget.delivery.userId!=null  ?
            size.height*0.56: size.height*0.67 -(size.width>360? 0: size.height*0.11),
            child: ListView.builder(
              controller: _scrollController,
                itemCount: conversation.messages!.length,
                itemBuilder: (context,index){
                  ChatMessageEntity currentMessage  = conversation.messages![index];
                  return  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: currentMessage.isFromAdmin! ?CrossAxisAlignment.start:CrossAxisAlignment.end,
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                color: currentMessage.isFromAdmin!?
                                Color(0x77a4ddff):
                                KabaChineColors.primary,
                                borderRadius: currentMessage.isFromAdmin!?
                                BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                            :
                                BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                              ),
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(currentMessage.content!,
                                    style: TextStyle(
                                      color:  currentMessage.isFromAdmin!?Colors.black54:
                                      Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  currentMessage.id.toString().length<10 ?
                                  Container():
                              currentMessage.isFromAdmin==false? Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Container(child: currentMessage.isRead! ?Icon(FontAwesomeIcons.checkDouble,color: Colors.white,size: 16):
                                      Icon(FontAwesomeIcons.check,color: Colors.white,size: 16)),
                                    ],
                                  ):Container()
                                ],
                              )
                          )
                        ],
                      ),
                    ),
                  );
                 }),
          ),
          Container(
            width: size.width*.98,
            height:80,
            color: Colors.white,
            child: Row(children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: messageController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      fillColor: Color(0x22a4ddff) ,
                      filled: true,
                      hintText: "Taper votre message ici...",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50),
                      )
                    ),
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: KabaChineColors.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () async{
                    if (messageController.text.isNotEmpty) {
                      ChatMessageEntity message = await sendMessage(message: messageController.text, conversation: widget.conversation);
                      BlocProvider.of<ChatBloc>(context).add(sendMessageLocalEvent(message: message,deliveryRequestId: widget.delivery.id.toString()));
                      messageController.clear();
                    }
                  },
                ),
              )
            ],),
          )
        ]
          );
        },
      ),
    );
  }
}
