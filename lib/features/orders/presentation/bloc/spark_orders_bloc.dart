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

  SparkOrdersBloc({
    required GetSparkOrdersUseCase getSparkOrdersUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required NotificationService notificationService,
  }) : _getSparkOrdersUseCase = getSparkOrdersUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       super(SparkOrdersInitial()) {
    on<LoadSparkOrdersEvent>(_onLoadSparkOrders);
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
  }

  Future<void> _onLoadSparkOrders(
    LoadSparkOrdersEvent event,
    Emitter<SparkOrdersState> emit,
  ) async {
    logger.i('Loading orders for Spark: ${event.sparkId}');
    emit(SparkOrdersLoading());
    try {
      await emit.forEach<List<OrderEntity>>(
        _getSparkOrdersUseCase(event.sparkId),
        onData: (orders) {
          logger.i('Received ${orders.length} orders');
          final pendingOrders = orders
              .where((o) => o.status == OrderStatus.pendingSparkAcceptance)
              .toList();
          logger.i('${pendingOrders.length} pending orders');
          return SparkOrdersLoaded(
            orders: orders,
            pendingOrders: pendingOrders,
          );
        },
        onError: (error, stackTrace) {
          logger.e('Stream error: $error');
          return SparkOrdersError(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error loading orders: $e');
      emit(SparkOrdersError(message: e.toString()));
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
