import 'dart:io';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

import '../../../models/CustomerModel.dart';
import '../../../models/MessageModel/messageModel.dart';
import '../../../resources/socket/sockets.dart';
import '../../../utils/_static_data/ServerRoutes.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../customwidgets/Chat/OwnMessage.dart';
import '../../customwidgets/Chat/ReplyMessageCard.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final int receiverId;

  const ChatPage({super.key, required this.token, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  List<MessageModel> messages = [];
  int? customerId;
  String customerName = '';
  bool sendButton = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();

    // 🔹 Reset unread count when opening chat
    SocketService().resetUnread();

    // 🔹 Listen to new incoming messages
    SocketService().messagesStream.listen((msg) {
      final senderId = msg["senderId"];
      final text = msg["text"];
      if (senderId.toString() != customerId.toString()) {
        _addMessage(MessageModel(
          message: text,
          type: "destination",
          messageType: text.startsWith("http") ? "image" : "text",
          senderName: msg["senderName"] ?? "Service Client",
          time: DateTime.parse(msg["createdAt"]),
        ));
      }
    });
  }

  Future<void> _initData() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    customerId = int.parse(customer.phone_number!.replaceAll(RegExp(r'\D'), ''));
    customerName = customer.nickname ?? "";

    // Initialize socket
    SocketService().init(customerId.toString());

    // 🔹 Fetch chat history from backend
    SocketService().fetchChatHistory(widget.receiverId.toString());

    // 🔹 Listen for chat history once it arrives
    SocketService().historyStream.listen((history) {
      setState(() {
        messages = history.map((m) {
          final isMine = m['senderId'].toString() == customerId.toString();
          return MessageModel(
            message: m['text'] ?? '',
            type: isMine ? 'source' : 'destination',
            messageType: (m['text'] ?? '').startsWith('http') ? 'image' : 'text',
            senderName: m['senderName'] ?? (isMine ? 'You' : 'Service Client'),
            time: DateTime.parse(m['createdAt']),
          );
        }).toList();
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }


  void _addMessage(MessageModel msg) {
    messages.add(msg);
    _listKey.currentState?.insertItem(messages.length - 1, duration: const Duration(milliseconds: 300));
    _scrollToBottom();
  }

  void sendMessage(String text) {
    if (customerId == null || text.trim().isEmpty) return;

    final messageData = {
      "senderId": customerId,
      "receiverId": widget.receiverId,
      "text": text.trim(),
      "senderName": customerName,
    };

    SocketService().socket?.emit("/message", messageData);

    _addMessage(MessageModel(
      message: text.trim(),
      type: "source",
      messageType: text.startsWith("http") ? "image" : "text",
      senderName: "You",
      time: DateTime.now(),
    ));

    _controller.clear();
    setState(() => sendButton = false);
  }

  Future<void> pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || customerId == null) return;

    try {
      final file = File(image.path);
      final uploadUrl = ServerRoutes.KABA_CHAT + "/upload-image";
      final fileName = path.basename(file.path);

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(uploadUrl, data: formData);
      final imageUrl = response.data["url"];

      _addMessage(MessageModel(
        message: imageUrl,
        type: "source",
        messageType: "image",
        senderName: "You",
        time: DateTime.now(),
      ));

      SocketService().socket?.emit("/message", {
        "senderId": customerId,
        "receiverId": widget.receiverId,
        "text": imageUrl,
        "senderName": customerName,
      });
    } catch (e) {
      print("❌ Image upload failed: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: KColors.primaryColor,
        elevation: 2,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/images/logo-chat.jpeg"),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              "Service Client Kaba",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AnimatedList(
                key: _listKey,
                controller: _scrollController,
                initialItemCount: messages.length,
                itemBuilder: (context, index, animation) {
                  final msg = messages[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: msg.type == "source"
                        ? OwnMessageCard(
                      message: msg.message,
                      messageType: msg.messageType,
                      time: msg.time,
                      senderName: msg.senderName,
                    )
                        : ReplyMessageCard(
                      message: msg.message,
                      messageType: msg.messageType,
                      time: msg.time,
                      senderName: msg.senderName,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.grey),
                    onPressed: pickAndSendImage,
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: _controller,
                        onChanged: (value) => setState(() => sendButton = value.isNotEmpty),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: KColors.primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) sendMessage(_controller.text.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),
        
          ],
        ),
      ),
    );
  }
}
