import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/domain/usecases/get_spark_orders.dart';
import 'package:sparkd/features/orders/domain/usecases/update_order_status.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:sparkd/core/utils/logger.dart';

class SparkOrdersBloc extends Bloc<SparkOrdersEvent, SparkOrdersState> {
  final GetSparkOrdersUseCase _getSparkOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  String? _currentSparkId;

  SparkOrdersBloc({
    required GetSparkOrdersUseCase getSparkOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required NotificationService notificationService,
  }) : _getSparkOrdersUseCase = getSparkOrdersUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       super(SparkOrdersInitial()) {
    on<LoadSparkOrdersEvent>(_onLoadSparkOrders);
    on<SparkOrderStatusFilterChanged>(_onSparkOrderStatusFilterChanged);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
  }

  Future<void> _onLoadSparkOrders(
    LoadSparkOrdersEvent event,
    Emitter<SparkOrdersState> emit,
  ) async {
    logger.i('Loading orders for Spark: ${event.sparkId}');
    emit(SparkOrdersLoading(currentStatus: event.status));
    _currentSparkId = event.sparkId;

    try {
      final orderStatus = _parseStatusString(event.status);

      await emit.forEach<List<OrderEntity>>(
        _getSparkOrdersUseCase(event.sparkId, status: orderStatus),
        onData: (orders) {
          logger.i('Received ${orders.length} orders');
          final pendingOrders = orders
              .where((o) => o.status == OrderStatus.pendingSparkAcceptance)
              .toList();
          logger.i('${pendingOrders.length} pending orders');
          return SparkOrdersLoaded(
            orders: orders,
            pendingOrders: pendingOrders,
            currentStatus: event.status,
          );
        },
        onError: (error, stackTrace) {
          logger.e('Stream error: $error');
          return SparkOrdersError(
            message: error.toString(),
            currentStatus: event.status,
          );
        },
      );
    } catch (e) {
      logger.e('Error loading orders: $e');
      emit(
        SparkOrdersError(message: e.toString(), currentStatus: event.status),
      );
    }
  }

  Future<void> _onSparkOrderStatusFilterChanged(
    SparkOrderStatusFilterChanged event,
    Emitter<SparkOrdersState> emit,
  ) async {
    if (_currentSparkId == null) return;

    emit(SparkOrdersLoading(currentStatus: event.status));

    final orderStatus = _parseStatusString(event.status);

    try {
      await emit.forEach<List<OrderEntity>>(
        _getSparkOrdersUseCase(_currentSparkId!, status: orderStatus),
        onData: (orders) {
          logger.i('Received ${orders.length} filtered orders');
          final pendingOrders = orders
              .where((o) => o.status == OrderStatus.pendingSparkAcceptance)
              .toList();
          return SparkOrdersLoaded(
            orders: orders,
            pendingOrders: pendingOrders,
            currentStatus: event.status,
          );
        },
        onError: (error, stackTrace) {
          logger.e('Stream error: $error');
          return SparkOrdersError(
            message: error.toString(),
            currentStatus: event.status,
          );
        },
      );
    } catch (e) {
      logger.e('Error filtering orders: $e');
      emit(
        SparkOrdersError(message: e.toString(), currentStatus: event.status),
      );
    }
  }

  /// Converts status string to OrderStatus enum
  /// Returns null if status is "all" or null (meaning show all orders)
  OrderStatus? _parseStatusString(String? status) {
    if (status == null || status.toLowerCase() == 'all') {
      return null;
    }

    try {
      return OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _onAcceptOrder(
    AcceptOrderEvent event,
    Emitter<SparkOrdersState> emit,
  ) async {
    try {
      emit(OrderUpdating());

      await _updateOrderStatusUseCase(event.orderId, {
        'status': OrderStatus.pendingPayment.toString().split('.').last,
        'acceptedAt': Timestamp.now(),
      });

      // Send notification to SME (will be handled by Cloud Function)
      logger.i('Order ${event.orderId} accepted');

      emit(OrderUpdateSuccess(message: 'Order accepted successfully!'));
    } catch (e) {
      logger.e('Error accepting order: $e');
      emit(OrderUpdateError(message: e.toString()));
    }
  }

  Future<void> _onRejectOrder(
    RejectOrderEvent event,
    Emitter<SparkOrdersState> emit,
  ) async {
    try {
      emit(OrderUpdating());

      await _updateOrderStatusUseCase(event.orderId, {
        'status': OrderStatus.cancelled.toString().split('.').last,
        'rejectionReason': event.reason,
        'rejectedAt': Timestamp.now(),
      });

      logger.i('Order ${event.orderId} rejected');

      emit(OrderUpdateSuccess(message: 'Order rejected'));
    } catch (e) {
      logger.e('Error rejecting order: $e');
      emit(OrderUpdateError(message: e.toString()));
    }
  }
}
