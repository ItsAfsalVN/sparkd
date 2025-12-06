import 'package:sparkd/features/orders/data/datasources/order_remote_repository.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/repository/order_repository.dart';

class OrderRepositoryImplementation implements OrderRepository {
  final OrderRemoteRepository _remoteRepository;

  OrderRepositoryImplementation({
    required OrderRemoteRepository remoteRepository,
  }) : _remoteRepository = remoteRepository;

  @override
  Future<String> createOrderRequest(OrderEntity order) async {
    return await _remoteRepository.createOrderRequest(order);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    Map<String, dynamic> updates,
  ) async {
    return await _remoteRepository.updateOrderStatus(orderId, updates);
  }

  @override
  Future<OrderEntity> getOrder(String orderId) async {
    return await _remoteRepository.getOrder(orderId);
  }

  @override
  Stream<List<OrderEntity>> getSparkOrders(String sparkId) {
    return _remoteRepository.getSparkOrders(sparkId);
  }

  @override
  Stream<List<OrderEntity>> getSmeOrders(String smeId) {
    return _remoteRepository.getSmeOrders(smeId);
  }
}
