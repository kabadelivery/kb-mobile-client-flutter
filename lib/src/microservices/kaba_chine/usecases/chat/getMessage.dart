import '../../domain/chat/chat_message_entity.dart';
import '../../domain/chat/repository.dart';

class GetMessages {
  final ChatRepository repo;
  GetMessages(this.repo);

  Future<List<ChatMessageEntity>> call({
    required String conversationId,
    int? limit,
    int? offset,
  }) async {
    return repo.getMessages(conversationId: conversationId, limit: limit, offset: offset);
  }
}
