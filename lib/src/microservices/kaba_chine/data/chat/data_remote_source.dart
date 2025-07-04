import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import 'chat_conversation_model.dart';
import 'chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatMessageModel>> getMessages({
    required String conversationId,
    int? limit,
    int? offset,
  });

  Future<ChatMessageModel?> sendMessage(ChatMessageModel message);

  Future<bool> markMessagesAsRead({
    required String conversationId,
    required bool isAdmin,
  });
  Future<List<ChatConversationModel>> getConversations(String userId);
  Future<bool> deleteConversation(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final http.Client client;
  ChatRemoteDataSourceImpl(this.client);


  @override
  Future<List<ChatConversationModel>> getConversations(String userId) async {
    final uri = Uri.parse('$LINK_CHAT_GET_CONVERSATIONS?userId=$userId');
    try {
      final resp = await client.get(uri);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final List jsonList = json.decode(resp.body);
        debugPrint('Response body: ${resp.body}');
        return jsonList.map((e) => ChatConversationModel.fromJson(e)).toList();
      } else {
        debugPrint('Erreur API getConversations: ${resp.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception getConversations: $e');
      return [];
    }
  }
  @override
  Future<List<ChatMessageModel>> getMessages({required String conversationId, int? limit, int? offset}) async {
    final params = {
      'conversationId': conversationId,
      if (limit != null) 'limit': limit.toString(),
      if (offset != null) 'offset': offset.toString(),
    };
    final uri = Uri.parse(LINK_CHAT_GET_MESSAGES).replace(queryParameters: params);
    final resp = await client.get(uri);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final List jsonList = json.decode(resp.body);
      debugPrint('Response body: ${jsonList}');
      return jsonList.map((j) => ChatMessageModel.fromJson(j)).toList();
    } else {
      debugPrintStack();
      debugPrint('Error getting messages: ${resp.statusCode}');
      return [];
    }
  }

  @override
  Future<ChatMessageModel?> sendMessage(ChatMessageModel message) async {
    final uri = Uri.parse(LINK_CHAT_GET_MESSAGES);

    Map <String, dynamic> messageRequest = message.conversationId!.isEmpty?{
      'content': message.content,
      'kabaUserId': message.kabaUserId.toString(),
      'adminId': message.adminId,
      'isFromAdmin': message.isFromAdmin,
      'deliveryRequestId': message.deliveryRequestId
    }:
    {
      'content': message.content,
      'kabaUserId': message.kabaUserId,
      'adminId': message.adminId,
      'isFromAdmin': message.isFromAdmin,
      'conversationId': message.conversationId,
      'deliveryRequestId': message.deliveryRequestId
    };
    final resp = await client.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(messageRequest)
    );
    debugPrint('Response body: ${messageRequest}');
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      debugPrint('Response body: ${resp.body}');
      return ChatMessageModel.fromJson(json.decode(resp.body));
    } else {
      debugPrintStack();
      debugPrint('Error sending message: ${resp.statusCode}');
    }
  }

  @override
  Future<bool> markMessagesAsRead({required String conversationId, required bool isAdmin}) async {
    final uri = Uri.parse(LINK_MARK_AS_READ);
    final resp = await client.put(uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'conversationId': conversationId, 'isAdmin': isAdmin})
    );
    return resp.statusCode == 200 || resp.statusCode == 201;
  }
  @override
  Future<bool> deleteConversation(String conversationId) async {
    final uri = Uri.parse(('$LINK_CHAT_GET_CONVERSATIONS/$conversationId'));
    final resp = await client.delete(uri);
    return resp.statusCode == 200;
  }
}
