import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/domain/usecases/get_sme_orders_usecase.dart';
import 'package:sparkd/features/orders/domain/usecases/update_order_status.dart';
import 'package:sparkd/core/utils/logger.dart';

part 'sme_order_event.dart';
part 'sme_order_state.dart';

class SmeOrderBloc extends Bloc<SmeOrderEvent, SmeOrderState> {
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final GetSmeOrdersUsecase _getSmeOrdersUsecase;
  String? _currentSmeId;
  String? _currentStatusFilter;

  SmeOrderBloc({
    required GetSmeOrdersUsecase getSmeOrdersUsecase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _getSmeOrdersUsecase = getSmeOrdersUsecase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       super(SmeOrderBlocInitial()) {
    on<SmeOrdersRequested>(_onSmeOrdersRequested);
    on<SmeOrderStatusFilterChanged>(_onSmeOrderStatusFilterChanged);
    on<SmeOrderRefreshRequested>(_onSmeOrderRefreshRequested);
    on<MarkOrderAsPaidEvent>(_onMarkOrderAsPaidEvent);
  }

  Future<void> _onSmeOrdersRequested(
    SmeOrdersRequested event,
    Emitter<SmeOrderState> emit,
  ) async {
    emit(SmeOrderBlocLoading(currentStatus: event.status));
    _currentSmeId = event.smeId;
    _currentStatusFilter = event.status;

    final orderStatus = _parseStatusString(event.status);

    return emit.forEach<List<OrderEntity>>(
      _getSmeOrdersUsecase.call(event.smeId, status: orderStatus),
      onData: (orders) =>
          SmeOrderBlocLoaded(orders: orders, currentStatus: event.status),
      onError: (error, stackTrace) => SmeOrderBlocError(
        message: error.toString(),
        currentStatus: event.status,
      ),
    );
  }

  Future<void> _onSmeOrderStatusFilterChanged(
    SmeOrderStatusFilterChanged event,
    Emitter<SmeOrderState> emit,
  ) async {
    if (_currentSmeId == null) return;

    emit(SmeOrderBlocLoading(currentStatus: event.status));
    _currentStatusFilter = event.status;

    final orderStatus = _parseStatusString(event.status);

    return emit.forEach<List<OrderEntity>>(
      _getSmeOrdersUsecase.call(_currentSmeId!, status: orderStatus),
      onData: (orders) =>
          SmeOrderBlocLoaded(orders: orders, currentStatus: event.status),
      onError: (error, stackTrace) => SmeOrderBlocError(
        message: error.toString(),
        currentStatus: event.status,
      ),
    );
  }

  Future<void> _onSmeOrderRefreshRequested(
    SmeOrderRefreshRequested event,
    Emitter<SmeOrderState> emit,
  ) async {
    final status = event.status ?? _currentStatusFilter;
    emit(SmeOrderBlocLoading(currentStatus: status));
    _currentSmeId = event.smeId;
    _currentStatusFilter = status;

    final orderStatus = _parseStatusString(status);

    return emit.forEach<List<OrderEntity>>(
      _getSmeOrdersUsecase.call(event.smeId, status: orderStatus),
      onData: (orders) =>
          SmeOrderBlocLoaded(orders: orders, currentStatus: status),
      onError: (error, stackTrace) =>
          SmeOrderBlocError(message: error.toString(), currentStatus: status),
    );
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

  Future<void> _onMarkOrderAsPaidEvent(
    MarkOrderAsPaidEvent event,
    Emitter<SmeOrderState> emit,
  ) async {
    try {
      emit(OrderStatusUpdateInProgress());

      await _updateOrderStatusUseCase.call(event.orderId, {
        'status': OrderStatus.inProgress.toString().split('.').last,
        'paidAt': Timestamp.now(),
      });

      emit(OrderStatusUpdateSuccess(orderId: event.orderId));
    } catch (e) {
      logger.e('Error marking order as paid: $e');
      emit(OrderStatusUpdateFailure(message: e.toString()));
    }
  }
}
