import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? socket;
  bool _connected = false;

  // Stream for new messages
  final StreamController<dynamic> _messageController = StreamController.broadcast();
  Stream<dynamic> get messagesStream => _messageController.stream;

  void init(String userId) {
    if (socket != null && _connected) return;

    socket = IO.io(
      "http://168.231.101.119:5000",
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
      _messageController.add(msg); // broadcast to listeners
    });

    socket!.onDisconnect((_) {
      print("❌ Socket disconnected globally!");
      _connected = false;
    });
  }

  void dispose() {
    socket?.disconnect();
    socket = null;
    _connected = false;
    _messageController.close();
  }
}
