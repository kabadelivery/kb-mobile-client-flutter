import '../../domain/chat/chat_conversation_entity.dart';
import '../../domain/chat/repository.dart';

class GetConversations {
  final ChatRepository repository;

  GetConversations(this.repository);

  Future<List<ChatConversationEntity>> call(String userId) {
    return repository.getConversations(userId);
  }
}