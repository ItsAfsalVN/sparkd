import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class GetSmeOrdersUsecase {
  final OrderRepository _repository;
  final String smeID;

  GetSmeOrdersUsecase({
    required OrderRepository repository,
    required this.smeID,
  }) : _repository = repository;

  Stream<List<OrderEntity>> call(String smeId, {OrderStatus? status}) {
    final stream = _repository.getSmeOrders(smeId);

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
