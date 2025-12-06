import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<String> createOrderRequest(OrderEntity order);
  Future<void> updateOrderStatus(String orderId, Map<String, dynamic> updates);
  Future<OrderEntity> getOrder(String orderId);
  Stream<List<OrderEntity>> getSparkOrders(String sparkId);
  Stream<List<OrderEntity>> getSmeOrders(String smeId);
}
