
import '../../domain/chat/repository.dart';

class DeleteConversation {
  final ChatRepository repo;
  DeleteConversation(this.repo);

  Future<bool> call(String conversationId) {
    return repo.deleteConversation(conversationId: conversationId);
  }
}