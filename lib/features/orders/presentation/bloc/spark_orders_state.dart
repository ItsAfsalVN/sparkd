import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

abstract class SparkOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SparkOrdersInitial extends SparkOrdersState {}

class SparkOrdersLoading extends SparkOrdersState {
  final String? currentStatus;

  SparkOrdersLoading({this.currentStatus});

  @override
  List<Object?> get props => [currentStatus];
}

class SparkOrdersLoaded extends SparkOrdersState {
  final List<OrderEntity> orders;
  final List<OrderEntity> pendingOrders;
  final String? currentStatus;

  SparkOrdersLoaded({
    required this.orders,
    required this.pendingOrders,
    this.currentStatus,
  });

  @override
  List<Object?> get props => [orders, pendingOrders, currentStatus];
}

class SparkOrdersError extends SparkOrdersState {
  final String message;
  final String? currentStatus;

  SparkOrdersError({required this.message, this.currentStatus});

  @override
  List<Object?> get props => [message, currentStatus];
}

class OrderUpdating extends SparkOrdersState {}

class OrderUpdateSuccess extends SparkOrdersState {
  final String message;

  OrderUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderUpdateError extends SparkOrdersState {
  final String message;

  OrderUpdateError({required this.message});

  @override
  List<Object?> get props => [message];
}
