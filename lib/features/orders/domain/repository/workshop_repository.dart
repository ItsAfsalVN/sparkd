import 'package:file_picker/file_picker.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopRepository {
  Stream<List<WorkshopMessageEntity>> getWorkshopMessages(String orderId);
  Future<void> sendMessage(WorkshopMessageEntity message);
  Future<void> deleteMessage(String messageId);
  Future<void> uploadAttachment(
    String userId,
    String senderId,
    String senderName,
    String senderRole,
    String orderId,
    String messageText,
    PlatformFile file,
  );
  Future<String> downloadWorkshopFile({
    required String fileUrl,
    required String fileName,
  });
}
