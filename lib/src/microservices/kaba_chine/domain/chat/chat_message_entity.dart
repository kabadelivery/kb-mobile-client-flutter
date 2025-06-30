class ChatMessageEntity {
  final String? id;
  final String? content;
  final String? kabaUserId;
  final String? adminId;
  final bool? isFromAdmin;
  final bool? isRead;
  final String? createdAt;
  final String? updatedAt;
  final String? conversationId;
  final String? deliveryRequestId;

  ChatMessageEntity({
    this.id,
    this.content,
    this.kabaUserId,
    this.adminId,
    this.isFromAdmin,
    this.isRead,
    this.createdAt,
    this.updatedAt,
    this.conversationId,
    this.deliveryRequestId,
  });
}