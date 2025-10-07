import 'dart:io';
import 'package:KABA/src/utils/_static_data/KTheme.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../models/CustomerModel.dart';
import '../../../models/MessageModel/MessageModel.dart';
import '../../../utils/functions/CustomerUtils.dart';

import '../../customwidgets/Chat/OwnMessage.dart';
import '../../customwidgets/Chat/ReplyMessageCard.dart';
import '../home/me/MeNewAccountPage.dart';

class ChatPage extends StatefulWidget {
  final String token;
  final int receiverId;

  const ChatPage({
    super.key,
    required this.token,
    required this.receiverId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  final Dio _dio = Dio();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> messages = [];
  int? customerId;
  bool sendButton = false;

  // -------------------------- INIT --------------------------
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    CustomerModel customer = await CustomerUtils.getCustomer();

    String? digitsOnly = customer.phone_number?.replaceAll(RegExp(r'\D'), ''); // remove non-digits

    customerId = int.parse(digitsOnly!);

    _connectSocket();

    // Wait a bit and then request chat history
    Future.delayed(const Duration(milliseconds: 700), () {
      if (socket.connected && customerId != null) {
        socket.emit("/getMessages", {
          "userId": customerId,
          "otherId": 92109474,
        });
      }
    });

    setState(() {});
  }

  // -------------------------- SOCKET --------------------------
  void _connectSocket() {
    socket = IO.io(
      "http://168.231.101.119:5000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("✅ Socket connected: ${socket.id}");

      if (customerId != null) {
        socket.emit("/register", customerId);
        print("🆔 Registered user ID: $customerId");
      }
    });

    socket.on("messages", (history) {
      print("📜 Received ${history.length} messages");
      setState(() {
        messages = (history as List)
            .map((msg) => MessageModel(
          message: msg["text"],
          type: msg["senderId"] == customerId
              ? "source"
              : "destination",
        ))
            .toList();
      });
      _scrollToBottom();
    });

    socket.on("message", (msg) {
      final senderId = msg["senderId"];
      final receiverId = msg["receiverId"];
      final text = msg["text"];

      print("💬 New message: $text");

      // Prevent duplicate local echo
      final isDuplicate = messages.isNotEmpty &&
          messages.last.message == text &&
          msg["senderId"] == customerId;

      if (isDuplicate) return;

      setState(() {
        messages.add(
          MessageModel(
            message: text,
            type: senderId == customerId ? "source" : "destination",
          ),
        );
      });
      _scrollToBottom();
    });


    socket.onDisconnect((_) {
      print("❌ Socket disconnected");
    });
  }

  // -------------------------- ACTIONS --------------------------
  void sendMessage(String text) {
    if (customerId == null || text.trim().isEmpty) return;

    final messageData = {
      "senderId": customerId,
      "receiverId": 92109474,
      "text": text.trim(),
    };

    socket.emit("/message", messageData);

    // Instantly show locally for sender
    final tempMessage = MessageModel(message: text.trim(), type: "source");
    setState(() {
      messages.add(tempMessage);
    });

    _controller.clear();
    setState(() => sendButton = false);
    _scrollToBottom();
  }

  Future<void> pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || customerId == null) return;

    try {
      final file = File(image.path);
      final uploadUrl = "http://168.231.101.119:5000/upload-image";
      final fileName = path.basename(file.path);

      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(uploadUrl, data: formData);
      final imageUrl = response.data["url"];

      print("✅ Image uploaded: $imageUrl");

      sendMessage(imageUrl);
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

  // -------------------------- DISPOSE --------------------------
  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }



  // -------------------------- UI --------------------------
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage:
                  AssetImage("assets/images/logo-chat.jpeg"),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 10),
                const Text(
                  "Service Client Kaba",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
      body: Column(
        children: [
          // ------------------ Chat history ------------------
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isImage = msg.message.startsWith("http");

                if (msg.type == "source") {
                  return OwnMessageCard(
                    message: msg.message,
                    messageType: isImage ? "image" : "text",
                    time: "00:00"
                  );
                } else {
                  return ReplyMessageCard(
                    message: msg.message,
                    messageType: isImage ? "image" : "text",
                      time: "00:00"
                  );
                }
              },
            ),
          ),

          // ------------------ Input area ------------------
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
                      onChanged: (value) =>
                          setState(() => sendButton = value.isNotEmpty),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: KColors.primaryColor,
                  child: IconButton(
                    icon: Icon(
                      sendButton ? Icons.send : Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        sendMessage(_controller.text.trim());
                      }
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