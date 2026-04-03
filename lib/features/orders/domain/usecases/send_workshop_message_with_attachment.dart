import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/domain/repository/workshop_repository.dart';

/// Use case to send a workshop message with an attached file
/// Following clean architecture: orchestrates the upload and message save
class SendWorkshopMessageWithAttachment {
  final WorkshopRepository _workshopRepository;

  SendWorkshopMessageWithAttachment({
    required WorkshopRepository workshopRepository,
  }) : _workshopRepository = workshopRepository;

  Future<void> call({
    required String userId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String orderId,
    required String messageText,
    required PlatformFile file,
  }) async {
    try {
      // Repository handles: upload file -> get URL -> create message -> save to Firestore
      await _workshopRepository.uploadAttachment(
        userId,
        senderId,
        senderName,
        senderRole,
        orderId,
        messageText,
        file,
      );
    } catch (e) {
      throw Exception('Failed to send message with attachment: $e');
    }
  }
}
