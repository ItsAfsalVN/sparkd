import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

class WorkshopMessageModel extends WorkshopMessageEntity {
  const WorkshopMessageModel({
    required String id,
    required String orderId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
    required DateTime sentAt,
    List<String>? attachmentUrls,
  }) : super(
         id: id,
         orderId: orderId,
         senderId: senderId,
         senderName: senderName,
         senderRole: senderRole,
         message: message,
         sentAt: sentAt,
         attachmentUrls: attachmentUrls,
       );

  factory WorkshopMessageModel.fromMap(Map<String, dynamic> map) {
    return WorkshopMessageModel(
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

  factory WorkshopMessageModel.fromEntity(WorkshopMessageEntity entity) {
    return WorkshopMessageModel(
      id: entity.id,
      orderId: entity.orderId,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderRole: entity.senderRole,
      message: entity.message,
      sentAt: entity.sentAt,
      attachmentUrls: entity.attachmentUrls,
    );
  }

  @override
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
}
