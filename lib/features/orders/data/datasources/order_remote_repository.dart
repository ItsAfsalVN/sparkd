import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:sparkd/features/orders/data/models/order_model.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/core/utils/logger.dart';

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
      logger.i('Creating order request for gig: ${order.gigID}');
      logger.d('Order data: ${order.toMap()}');
      final orderModel = OrderModel(order: order);
      final docRef = await _firestore
          .collection("orders")
          .add(orderModel.toJson())
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
              'Failed to create order request - connection timeout',
            ),
          );
      logger.i('Order created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      logger.e('Failed to create order request: $e');
      throw Exception('Failed to create order request: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection("orders")
          .doc(orderId)
          .update(updates)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
              'Failed to update order - connection timeout',
            ),
          );
      logger.i('Order $orderId status updated successfully');
    } catch (e) {
      logger.e('Failed to update order $orderId: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<OrderEntity> getOrder(String orderId) async {
    try {
      final doc = await _firestore
          .collection("orders")
          .doc(orderId)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(
              'Failed to fetch order - connection timeout',
            ),
          );
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      final data = doc.data()!;
      data['id'] = doc.id;
      return OrderModel.fromJson(data).order;
    } catch (e) {
      logger.e('Failed to get order $orderId: $e');
      throw Exception('Failed to get order: $e');
    }
  }

  @override
  Stream<List<OrderEntity>> getSparkOrders(String sparkId) {
    logger.i('Setting up stream for Spark orders: $sparkId');
    try {
      return _firestore
          .collection("orders")
          .where("sparkID", isEqualTo: sparkId)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) {
              logger.e('Firestore stream timeout for spark orders');
              sink.addError(
                Exception(
                  'Firestore connection timeout. Please check your internet connection.',
                ),
              );
            },
          )
          .map((snapshot) {
            logger.i(
              'Received snapshot with ${snapshot.docs.length} documents',
            );
            final orders = <OrderEntity>[];
            for (final doc in snapshot.docs) {
              try {
                final data = doc.data();
                data['id'] = doc.id;
                logger.d('Order data: $data');
                logger.d('createdAt type: ${data['createdAt'].runtimeType}');
                orders.add(OrderModel.fromJson(data).order);
              } catch (e) {
                logger.e('Error parsing order ${doc.id}: $e');
                // Skip this order and continue with others
              }
            }
            return orders;
          })
          .handleError((error) {
            logger.e('Error in getSparkOrders stream: $error');
            // Return empty list on error to allow UI to recover
            return <OrderEntity>[];
          });
    } catch (e) {
      logger.e('Error setting up getSparkOrders stream: $e');
      // Return error stream that the app can handle
      return Stream.error(Exception('Failed to set up orders stream: $e'));
    }
  }

  @override
  Stream<List<OrderEntity>> getSmeOrders(String smeId) {
    logger.i('Setting up stream for SME orders: $smeId');
    try {
      return _firestore
          .collection("orders")
          .where("smeID", isEqualTo: smeId)
          .orderBy("createdAt", descending: true)
          .snapshots()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: (sink) {
              logger.e('Firestore stream timeout for SME orders');
              sink.addError(
                Exception(
                  'Firestore connection timeout. Please check your internet connection.',
                ),
              );
            },
          )
          .map((snapshot) {
            logger.i(
              'Received SME orders snapshot with ${snapshot.docs.length} documents',
            );
            final orders = <OrderEntity>[];
            for (final doc in snapshot.docs) {
              try {
                final data = doc.data();
                data['id'] = doc.id;
                orders.add(OrderModel.fromJson(data).order);
              } catch (e) {
                logger.e('Error parsing SME order ${doc.id}: $e');
                // Skip this order and continue with others
              }
            }
            return orders;
          })
          .handleError((error) {
            logger.e('Error in getSmeOrders stream: $error');
            // Return empty list on error to allow UI to recover
            return <OrderEntity>[];
          });
    } catch (e) {
      logger.e('Error setting up getSmeOrders stream: $e');
      // Return error stream that the app can handle
      return Stream.error(Exception('Failed to set up SME orders stream: $e'));
    }
  }
}
