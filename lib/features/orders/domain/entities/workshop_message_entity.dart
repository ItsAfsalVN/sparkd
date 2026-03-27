class WorkshopMessageEntity {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'sme' or 'spark'
  final String message;
  final DateTime sentAt;
  final List<String>? attachmentUrls;

  const WorkshopMessageEntity({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.sentAt,
    this.attachmentUrls,
  });

  WorkshopMessageEntity copyWith({
    String? id,
    String? orderId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? sentAt,
    List<String>? attachmentUrls,
  }) {
    return WorkshopMessageEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'sentAt': sentAt.toIso8601String(),
      'attachmentUrls': attachmentUrls ?? [],
    };
  }

  factory WorkshopMessageEntity.fromMap(Map<String, dynamic> map) {
    return WorkshopMessageEntity(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? '',
      message: map['message'] ?? '',
      sentAt: DateTime.parse(map['sentAt'] ?? DateTime.now().toIso8601String()),
      attachmentUrls: List<String>.from(map['attachmentUrls'] ?? []),
    );
  }
}
