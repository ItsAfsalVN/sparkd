import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class GetSparkOrdersUseCase {
  final OrderRepository _repository;

  GetSparkOrdersUseCase({required OrderRepository repository})
    : _repository = repository;

  Stream<List<OrderEntity>> call(String sparkId) {
    return _repository.getSparkOrders(sparkId);
  }
}
