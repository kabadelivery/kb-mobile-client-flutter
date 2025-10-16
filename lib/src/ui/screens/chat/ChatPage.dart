import 'dart:io';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../models/CustomerModel.dart';
import '../../../models/MessageModel/messageModel.dart';
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
  late IO.Socket socket;
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  List<MessageModel> messages = [];
  int? customerId;
  String customerName = '';
  bool sendButton = false;
  bool _isLoading = true; // loading state

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    CustomerModel customer = await CustomerUtils.getCustomer();
    String? digitsOnly = customer.phone_number?.replaceAll(RegExp(r'\D'), '');
    customerId = int.parse(digitsOnly!);
    customerName = customer.nickname!;

    _connectSocket();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (socket.connected && customerId != null) {
        socket.emit("/getMessages", {
          "userId": customerId,
          "otherId": 92109474,
        });
      }
    });
  }

  void _connectSocket() {
    socket = IO.io(
      ServerRoutes.KABA_CHAT,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    socket.connect();

    socket.onConnect((_) {
      if (customerId != null) socket.emit("/register", customerId);
    });

    socket.on("messages", (history) {
      for (var msg in history) {
        _addMessage(MessageModel(
          message: msg["text"],
          type: msg["senderId"] == customerId ? "source" : "destination",
          messageType: msg["text"].startsWith("http") ? "image" : "text",
          senderName: msg["senderId"] == 92109474
              ? "Service Client"
              : (msg["senderId"] == customerId ? "You" : (msg["senderName"] ?? "Unknown")),
          time: DateTime.parse(msg["createdAt"]),
        ));
      }
      setState(() => _isLoading = false);
    });

    socket.on("message", (msg) {
      final senderId = msg["senderId"];
      final text = msg["text"];

      final isDuplicate = messages.isNotEmpty &&
          messages.last.message == text &&
          senderId == customerId;
      if (isDuplicate) return;

      _addMessage(MessageModel(
        message: text,
        type: senderId == customerId ? "source" : "destination",
        messageType: text.startsWith("http") ? "image" : "text",
        senderName: senderId == 92109474
            ? "Service Client"
            : (senderId == customerId ? "You" : (msg["senderName"] ?? "Unknown")),
        time: DateTime.parse(msg["createdAt"]),
      ));
    });

    socket.onDisconnect((_) {});
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
      "receiverId": 92109474,
      "text": text.trim(),
      "senderName": customerName,
    };

    socket.emit("/message", messageData);

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
      final uploadUrl = ServerRoutes.KABA_CHAT+"/upload-image";
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
      socket.emit("/message", {
        "senderId": customerId,
        "receiverId": 92109474,
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
    socket.dispose();
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
      body: Column(
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
                    icon: Icon(Icons.send, color: Colors.white),
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
    );
  }
}
