import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../models/CustomerModel.dart';
import '../../../models/MessageModel/MessageModel.dart';
import '../../customwidgets/Chat/OwnMessage.dart';
import '../../customwidgets/Chat/ReplyMessageCard.dart';
import '../../../utils/functions/CustomerUtils.dart';
import '../../../utils/_static_data/KTheme.dart';
import '../home/HomePage.dart';

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
  List<MessageModel> messages = [];
  int? customerId;

  late IO.Socket socket;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool sendButton = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // Load logged-in customer
    CustomerModel customer = await CustomerUtils.getCustomer();
    setState(() {
      customerId = customer.id;
    });

    // Connect socket after customerId is available
    _connect();
  }

  void _connect() {
    socket = IO.io(
      "http://192.168.1.104:5000",
      <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": true, // auto connect enabled
      },
    );

    socket.onConnect((_) {
      print("✅ Socket connected: ${socket.id}");
      if (customerId != null) {
        socket.emit("/register", customerId); // register user automatically
        print("🆔 Registered as user $customerId");
      }
    });

    // Receive new messages
    socket.on("message", (msg) {
      print("💬 Message received: $msg");
      setState(() {
        messages.add(MessageModel(
          message: msg["text"],
          type: msg["senderId"] == customerId ? "source" : "destination",
        ));
      });
      _scrollToBottom();
    });

    socket.on("error", (err) {
      print("⚠️ Server error: $err");
    });

    socket.onDisconnect((_) {
      print("❌ Socket disconnected");
    });
  }

  void sendMessage(String message) {
    if (customerId == null || message.trim().isEmpty) return;

    // Add locally
    setState(() {
      messages.add(MessageModel(message: message, type: "source"));
    });
    _scrollToBottom();

    // Send via socket
    socket.emit("/message", {
      "senderId": customerId,
      "receiverId": widget.receiverId,
      "text": message,
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
      appBar: AppBar(
        leadingWidth: 70,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.arrow_back),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey,
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Service Client Kaba",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "last seen today ${customerId ?? ''}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
        backgroundColor: KColors.primaryColor,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (messages[index].type == "source") {
                  return OwnMessageCard(message: messages[index].message);
                } else {
                  return ReplyMessageCard(message: messages[index].message);
                }
              },
            ),
          ),

          // Input area with photo & file icons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.grey),
                  onPressed: () {
                    print("📷 Select photo clicked");
                    // TODO: implement photo picker
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    print("📎 Attach file clicked");
                    // TODO: implement file picker
                  },
                ),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: TextFormField(
                      controller: _controller,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: (value) {
                        setState(() {
                          sendButton = value.isNotEmpty;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: KColors.primaryColor,
                  child: IconButton(
                    icon: Icon(
                      sendButton ? Icons.send : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        sendMessage(_controller.text.trim());
                        _controller.clear();
                        setState(() => sendButton = false);
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
