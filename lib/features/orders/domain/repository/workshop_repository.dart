import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopRepository {
  Stream<List<WorkshopMessageEntity>> getWorkshopMessages(String orderId);
  Future<void> sendMessage(WorkshopMessageEntity message);
  Future<void> deleteMessage(String messageId);
}
