import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sparkd/features/orders/data/models/order_model.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

abstract class OrderRemoteRepository {
  Future<String> createOrderRequest(OrderEntity order);
  Future<void> updateOrderStatus(String orderId, Map<String, dynamic> updates);
  Future<OrderEntity> getOrder(String orderId);
  Stream<List<OrderEntity>> getSparkOrders(String sparkId);
  Stream<List<OrderEntity>> getSmeOrders(String smeId);
}

class OrderRemoteRepositoryImplementation implements OrderRemoteRepository {
  final FirebaseFirestore _firestore;

  OrderRemoteRepositoryImplementation({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<String> createOrderRequest(OrderEntity order) async {
    try {
      final orderModel = OrderModel(order: order);
      final docRef = await _firestore
          .collection("orders")
          .add(orderModel.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order request: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection("orders").doc(orderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<OrderEntity> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection("orders").doc(orderId).get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return OrderModel.fromJson(data).order;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getSparkOrders(String sparkId) {
    try {
      return _firestore
          .collection("orders")
          .where("sparkID", isEqualTo: sparkId)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return OrderModel.fromJson(data).order;
            }).toList();
          });
    } catch (e) {
      throw Exception('Failed to get spark orders: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getSmeOrders(String smeId) {
    try {
      return _firestore
          .collection("orders")
          .where("smeID", isEqualTo: smeId)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return OrderModel.fromJson(data).order;
            }).toList();
          });
    } catch (e) {
      throw Exception('Failed to get sme orders: $e');
    }
  }
}
