import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkshopLoadMessages extends WorkshopEvent {
  final String orderId;

  WorkshopLoadMessages({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class WorkshopSendMessage extends WorkshopEvent {
  final WorkshopMessageEntity message;

  WorkshopSendMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopDeleteMessage extends WorkshopEvent {
  final String messageId;

  WorkshopDeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class WorkshopUploadMessageWithAttachment extends WorkshopEvent {
  final String userId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String orderId;
  final String messageText;
  final PlatformFile file;

  WorkshopUploadMessageWithAttachment({
    required this.userId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.orderId,
    required this.messageText,
    required this.file,
  });

  @override
  List<Object?> get props => [
    userId,
    senderId,
    senderName,
    senderRole,
    orderId,
    messageText,
    file,
  ];
}

class WorkshopDownloadFile extends WorkshopEvent {
  final String fileUrl;
  final String fileName;

  WorkshopDownloadFile({required this.fileUrl, required this.fileName});

  @override
  List<Object?> get props => [fileUrl, fileName];
}
