import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/data/datasources/workshop_remote_data_source.dart';
import 'package:sparkd/features/orders/data/models/workshop_message_model.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';
import 'package:sparkd/features/orders/domain/repository/workshop_repository.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopRemoteDataSource _remoteDataSource;

  WorkshopRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<WorkshopMessageEntity>> getWorkshopMessages(String orderId) {
    return _remoteDataSource
        .getWorkshopMessages(orderId)
        .map((messages) => messages.cast<WorkshopMessageEntity>());
  }

  @override
  Future<void> sendMessage(WorkshopMessageEntity message) {
    return _remoteDataSource.sendMessage(
      WorkshopMessageModel.fromEntity(message),
    );
  }

  @override
  Future<void> deleteMessage(String messageId) {
    return _remoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<void> uploadAttachment(
    String userId,
    String senderId,
    String senderName,
    String senderRole,
    String orderId,
    String messageText,
    PlatformFile file,
  ) {
    return _remoteDataSource.uploadAttachment(
      userId,
      senderId,
      senderName,
      senderRole,
      orderId,
      messageText,
      file,
    );
  }

}