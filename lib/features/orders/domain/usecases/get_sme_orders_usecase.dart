import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class GetSmeOrdersUsecase {
  final OrderRepository _repository;

  GetSmeOrdersUsecase({required OrderRepository repository})
    : _repository = repository;

  Stream<List<OrderEntity>> call(String smeId) {
    return _repository.getSmeOrders(smeId);
  }
}
