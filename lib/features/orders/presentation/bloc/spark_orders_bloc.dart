import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/domain/usecases/get_spark_orders.dart';
import 'package:sparkd/features/orders/domain/usecases/update_order_status.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:logger/logger.dart';

class SparkOrdersBloc extends Bloc<SparkOrdersEvent, SparkOrdersState> {
  final GetSparkOrdersUseCase _getSparkOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final Logger _logger = Logger();
  StreamSubscription? _ordersSubscription;

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
    _logger.i('Loading orders for Spark: ${event.sparkId}');
    emit(SparkOrdersLoading());
    try {
      await _ordersSubscription?.cancel();
      _ordersSubscription = _getSparkOrdersUseCase(event.sparkId).listen(
        (orders) {
          _logger.i('Received ${orders.length} orders');
          final pendingOrders = orders
              .where((o) => o.status == OrderStatus.pendingSparkAcceptance)
              .toList();
          _logger.i('${pendingOrders.length} pending orders');
          emit(SparkOrdersLoaded(orders: orders, pendingOrders: pendingOrders));
        },
        onError: (error) {
          _logger.e('Stream error: $error');
          emit(SparkOrdersError(message: error.toString()));
        },
      );
    } catch (e) {
      _logger.e('Error loading orders: $e');
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
        'acceptedAt': DateTime.now().toIso8601String(),
      });

      // Send notification to SME (will be handled by Cloud Function)
      _logger.i('Order ${event.orderId} accepted');

      emit(OrderUpdateSuccess(message: 'Order accepted successfully!'));
    } catch (e) {
      _logger.e('Error accepting order: $e');
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
        'rejectedAt': DateTime.now().toIso8601String(),
      });

      _logger.i('Order ${event.orderId} rejected');

      emit(OrderUpdateSuccess(message: 'Order rejected'));
    } catch (e) {
      _logger.e('Error rejecting order: $e');
      emit(OrderUpdateError(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
