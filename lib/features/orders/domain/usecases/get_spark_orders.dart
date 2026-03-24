import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class GetSparkOrdersUseCase {
  final OrderRepository _repository;

  GetSparkOrdersUseCase({required OrderRepository repository})
    : _repository = repository;

  Stream<List<OrderEntity>> call(String sparkId, {OrderStatus? status}) {
    final stream = _repository.getSparkOrders(sparkId);

    if (status == null) {
      // Return all orders
      return stream;
    }

    // Filter orders by status
    return stream.map((orders) {
      return orders.where((order) => order.status == status).toList();
    });
  }
}
