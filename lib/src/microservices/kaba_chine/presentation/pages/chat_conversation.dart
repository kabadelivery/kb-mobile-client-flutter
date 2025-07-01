import 'package:KABA/src/microservices/kaba_chine/core/utils.dart';
import 'package:KABA/src/microservices/kaba_chine/data/order/delivery_model.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_message_entity.dart';
import 'package:KABA/src/microservices/kaba_chine/presentation/bloc/chat/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/chat/chat_conversation_entity.dart';
import '../../functions/crud_chat.dart';
import 'delivery_details.dart';

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
  @override
  void initState() {
    conversation = widget.conversation;
    delivery= widget.delivery;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<ChatBloc, ChatState>(
  listener: (context, state) {
    if(state is sendMessageState){
      conversation.messages!.add(state.message);
    }
  },
  builder: (context, state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width:size.width,
            height: 100,
            color: KabaChineColors.primary,
            child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
                Text("Discussion sur KABA",style: TextStyle(color: Colors.white,fontSize: 16),),
                Container(),
              ],
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
                          Text("Discussion concernant la livraison en cours",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text("Voir la livraison",
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
          height:widget.delivery.userId!=null  ? size.height*0.56: size.height*0.67,
          child: ListView.builder(
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
                              borderRadius: currentMessage.isFromAdmin!?      BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20))
                          :
                              BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                            ),
                            padding: EdgeInsets.all(10.0),
                            child: Text(currentMessage.content!,
                              style: TextStyle(
                                color:  currentMessage.isFromAdmin!?Colors.black54:Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
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
                    BlocProvider.of<ChatBloc>(context).add(sendMessageEvent(message: message));
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
);
  }
}
