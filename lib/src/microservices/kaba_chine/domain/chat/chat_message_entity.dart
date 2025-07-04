class ChatMessageEntity {
   String? id;
   String? content;
   String? kabaUserId;
   String? adminId;
   bool? isFromAdmin;
   bool? isRead;
   String? createdAt;
   String? updatedAt;
   String? conversationId;
  String? deliveryRequestId;

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