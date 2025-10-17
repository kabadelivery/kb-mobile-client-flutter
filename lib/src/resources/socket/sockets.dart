import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../utils/_static_data/ServerRoutes.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  bool _connected = false;

  String? _currentUserId;

  // 🔹 Unread count
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // 🔹 Stream for new messages
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  Stream<dynamic> get messagesStream => _messageController.stream;

  // 🔹 Stream for unread count changes
  final StreamController<int> _unreadController = StreamController<int>.broadcast();
  Stream<int> get unreadStream => _unreadController.stream;

  // 🔹 Stream for chat history
  final StreamController<List<dynamic>> _historyController = StreamController.broadcast();
  Stream<List<dynamic>> get historyStream => _historyController.stream;




  void init(String userId) {
    _currentUserId = userId;

    if (socket != null && _connected) return;

    socket = IO.io(
      ServerRoutes.KABA_CHAT,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    socket!.onConnect((_) {
      print("✅ Socket connected globally!");
      socket!.emit("/register", userId);
      _connected = true;
    });

    socket!.on('message', (msg) {
      // Broadcast the message
      _messageController.add(msg);

      // Increment unread count only if the message is not from the current user
      if (msg["senderId"].toString() != _currentUserId) {
        _unreadCount++;
        _unreadController.add(_unreadCount);
      }
    });

    socket!.onDisconnect((_) {
      print("❌ Socket disconnected globally!");
      _connected = false;
    });
  }

  void resetUnread() {
    _unreadCount = 0;
    _unreadController.add(_unreadCount);
  }

  void dispose() {
    socket?.disconnect();
    socket = null;
    _connected = false;
    _messageController.close();
    _unreadController.close();
  }

  // 🔹 Fetch chat history from the server
  // 🔹 Fetch chat history from the server
  void fetchChatHistory(String otherUserId) {
    if (socket == null || !_connected || _currentUserId == null) return;

    socket!.emit("/getMessages", {
      "userId": int.tryParse(_currentUserId!) ?? _currentUserId,
      "otherId": int.tryParse(otherUserId) ?? otherUserId,
    });

    socket!.once("messages", (history) {
      if (history is List) {
        _historyController.add(history);
      } else {
        print("⚠️ Invalid history format received: $history");
      }
    });
  }

}
