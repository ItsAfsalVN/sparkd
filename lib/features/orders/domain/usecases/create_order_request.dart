import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class CreateOrderRequestUseCase {
  final OrderRepository _orderRepository;

  CreateOrderRequestUseCase({required OrderRepository orderRepository})
    : _orderRepository = orderRepository;

  Future<String> call(OrderEntity order) async {
    return await _orderRepository.createOrderRequest(order);
  }
}
