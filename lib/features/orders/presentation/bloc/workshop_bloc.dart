import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/orders/domain/usecases/download_workshop_file.dart';
import 'package:sparkd/features/orders/domain/usecases/workshop_usecases.dart';
import 'package:sparkd/features/orders/domain/usecases/send_workshop_message_with_attachment.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

class WorkshopBloc extends Bloc<WorkshopEvent, WorkshopState> {
  final GetWorkshopMessagesUseCase _getMessagesUseCase;
  final SendWorkshopMessageUseCase _sendMessageUseCase;
  final DeleteWorkshopMessageUseCase _deleteMessageUseCase;
  final SendWorkshopMessageWithAttachment _uploadMessageWithAttachmentUseCase;
  final DownloadWorkshopFileUseCase _downloadWorkshopFileUseCase;
  Map<String, String> _downloadedFilesCache =
      {}; // Map of file names to their local paths

  WorkshopBloc({
    required GetWorkshopMessagesUseCase getMessagesUseCase,
    required SendWorkshopMessageUseCase sendMessageUseCase,
    required DeleteWorkshopMessageUseCase deleteMessageUseCase,
    required SendWorkshopMessageWithAttachment
    uploadMessageWithAttachmentUseCase,
    required DownloadWorkshopFileUseCase downloadWorkshopFileUseCase,
  }) : _getMessagesUseCase = getMessagesUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _deleteMessageUseCase = deleteMessageUseCase,
       _uploadMessageWithAttachmentUseCase = uploadMessageWithAttachmentUseCase,
       _downloadWorkshopFileUseCase = downloadWorkshopFileUseCase,
       super(WorkshopInitial()) {
    on<WorkshopLoadMessages>(_onLoadMessages);
    on<WorkshopSendMessage>(_onSendMessage);
    on<WorkshopDeleteMessage>(_onDeleteMessage);
    on<WorkshopUploadMessageWithAttachment>(_onUploadMessageWithAttachment);
    on<WorkshopDownloadFile>(_onDownloadFile);
  }

  Future<void> _onLoadMessages(
    WorkshopLoadMessages event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      emit(WorkshopLoading());
      await emit.forEach(
        _getMessagesUseCase(event.orderId),
        onData: (messages) => WorkshopLoaded(messages: messages),
        onError: (error, stackTrace) {
          logger.e('Error loading messages: $error');
          return WorkshopError(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error in _onLoadMessages: $e');
      emit(WorkshopError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    WorkshopSendMessage event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      await _sendMessageUseCase(event.message);
      await emit.forEach(
        _getMessagesUseCase(event.message.orderId),
        onData: (messages) => WorkshopLoaded(messages: messages),
        onError: (error, stackTrace) {
          logger.e('Error loading messages: $error');
          return WorkshopError(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error sending message: $e');
      emit(WorkshopMessageSentError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMessage(
    WorkshopDeleteMessage event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      await _deleteMessageUseCase(event.messageId);
    } catch (e) {
      logger.e('Error deleting message: $e');
      emit(WorkshopError(message: e.toString()));
    }
  }

  Future<void> _onUploadMessageWithAttachment(
    WorkshopUploadMessageWithAttachment event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      emit(WorkshopAttachmentUploading());

      // Call use case to upload file and save message with attachment
      await _uploadMessageWithAttachmentUseCase(
        userId: event.userId,
        senderId: event.senderId,
        senderName: event.senderName,
        senderRole: event.senderRole,
        orderId: event.orderId,
        messageText: event.messageText,
        file: event.file,
      );

      // Reload messages after successful upload
      emit(
        WorkshopAttachmentUploadSuccess(
          fileUrl:
              '', // The file URL is stored in the message, not returned separately
          messageId: DateTime.now().toString(),
        ),
      );

      // Reload messages
      await emit.forEach(
        _getMessagesUseCase(event.orderId),
        onData: (messages) => WorkshopLoaded(messages: messages),
        onError: (error, stackTrace) {
          logger.e('Error loading messages after upload: $error');
          return WorkshopError(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error uploading attachment: $e');
      emit(WorkshopAttachmentUploadError(message: e.toString()));
    }
  }

  Future<void> _onDownloadFile(
    WorkshopDownloadFile event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      emit(WorkshopFileDownloadInProgress(progress: 0, fileUrl: event.fileUrl));

      final localPath = await _downloadWorkshopFileUseCase(
        fileUrl: event.fileUrl,
        fileName: event.fileName,
      );

      _downloadedFilesCache[event.fileUrl] = localPath;
      emit(WorkshopFileDownloadSuccess(downloadedFiles: _downloadedFilesCache));
    } catch (e) {
      logger.e('Error downloading file: $e');
      emit(WorkshopFileDownloadError(message: e.toString()));
    }
  }

  /// Get the cache of downloaded files
  Map<String, String> getDownloadedFilesCache() {
    return Map.from(_downloadedFilesCache);
  }
}
