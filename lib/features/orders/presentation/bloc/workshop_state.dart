import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopLoaded extends WorkshopState {
  final List<WorkshopMessageEntity> messages;

  WorkshopLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class WorkshopError extends WorkshopState {
  final String message;

  WorkshopError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopMessageSending extends WorkshopState {}

class WorkshopMessageSent extends WorkshopState {
  final WorkshopMessageEntity message;

  WorkshopMessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopMessageSentError extends WorkshopState {
  final String message;

  WorkshopMessageSentError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopAttachmentUploading extends WorkshopState {
  final double? progress;

  WorkshopAttachmentUploading({this.progress});

  @override
  List<Object?> get props => [progress];
}

class WorkshopAttachmentUploadSuccess extends WorkshopState {
  final String fileUrl;
  final String messageId;

  WorkshopAttachmentUploadSuccess({
    required this.fileUrl,
    required this.messageId,
  });

  @override
  List<Object?> get props => [fileUrl, messageId];
}

class WorkshopAttachmentUploadError extends WorkshopState {
  final String message;

  WorkshopAttachmentUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopFileDownloadInProgress extends WorkshopState {
  final double? progress;

  WorkshopFileDownloadInProgress({this.progress});

  @override
  List<Object?> get props => [progress];
}

class WorkshopFileDownloadSuccess extends WorkshopState {
  final Map<String, String> downloadedFiles; // Map of file names to their local paths
  WorkshopFileDownloadSuccess({required this.downloadedFiles});

  @override
  List<Object?> get props => [downloadedFiles];
}

class WorkshopFileDownloadError extends WorkshopState {
  final String message;

  WorkshopFileDownloadError({required this.message});

  @override
  List<Object?> get props => [message];
}
