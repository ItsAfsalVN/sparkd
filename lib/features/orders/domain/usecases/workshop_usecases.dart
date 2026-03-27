import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';
import 'package:sparkd/features/orders/domain/repository/workshop_repository.dart';

class GetWorkshopMessagesUseCase {
  final WorkshopRepository _repository;

  GetWorkshopMessagesUseCase(this._repository);

  Stream<List<WorkshopMessageEntity>> call(String orderId) {
    return _repository.getWorkshopMessages(orderId);
  }
}

class SendWorkshopMessageUseCase {
  final WorkshopRepository _repository;

  SendWorkshopMessageUseCase(this._repository);

  Future<void> call(WorkshopMessageEntity message) {
    return _repository.sendMessage(message);
  }
}

class DeleteWorkshopMessageUseCase {
  final WorkshopRepository _repository;

  DeleteWorkshopMessageUseCase(this._repository);

  Future<void> call(String messageId) {
    return _repository.deleteMessage(messageId);
  }
}
