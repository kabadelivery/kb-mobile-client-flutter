import '../../domain/chat/repository.dart';

class MarkMessagesAsRead {
  final ChatRepository repo;
  MarkMessagesAsRead(this.repo);

  Future<bool> call({required String conversationId, required bool isAdmin}) {
    return repo.markMessagesAsRead(conversationId: conversationId, isAdmin: isAdmin);
  }
}