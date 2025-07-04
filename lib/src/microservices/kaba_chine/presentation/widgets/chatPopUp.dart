import 'package:KABA/src/microservices/kaba_chine/Enums/messageType.dart';
import 'package:KABA/src/microservices/kaba_chine/domain/chat/chat_conversation_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Enums/deliveryStatus.dart';
import '../../core/utils.dart';
import '../../data/order/delivery_model.dart';
import '../../functions/crud_chat.dart';
import '../../functions/getStatusInfo.dart';
import '../bloc/chat/chat_bloc.dart';

void startChatPopUp({required BuildContext context}) {

  showDialog(context: context,

      builder:(BuildContext context){

          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Nouvelle conversation",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close,
                          color: Colors.black87,
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text("A propos de quelle lignes souhaitez-vous discuter ?",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width ,
                    height: 60,
                    child: MaterialButton(
                      onPressed: ()async {
                        ChatConversationEntity conversation = await createConversation(type: MessageType.GENERAL);
                        BlocProvider.of<ChatBloc>(context).add(createConversationEvent(chat: conversation));
                        Navigator.pop(context);
                      },
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      color: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      child: Center(
                        child: Text(
                          'Demande générale',
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      });
}