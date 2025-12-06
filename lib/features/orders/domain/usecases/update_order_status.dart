import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase({required OrderRepository repository})
    : _repository = repository;

  Future<void> call(String orderId, Map<String, dynamic> updates) async {
    return await _repository.updateOrderStatus(orderId, updates);
  }
}
