import '../../domain/chat/chat_message_entity.dart';
import '../../domain/chat/repository.dart';

class SendMessage {
  final ChatRepository repo;
  SendMessage(this.repo);

  Future<ChatMessageEntity?> call(ChatMessageEntity msg) {

    return repo.sendMessage(message: msg);
  }
}