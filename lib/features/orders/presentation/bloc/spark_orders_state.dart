import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

abstract class SparkOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SparkOrdersInitial extends SparkOrdersState {}

class SparkOrdersLoading extends SparkOrdersState {}

class SparkOrdersLoaded extends SparkOrdersState {
  final List<OrderEntity> orders;
  final List<OrderEntity> pendingOrders;

  SparkOrdersLoaded({required this.orders, required this.pendingOrders});

  @override
  List<Object?> get props => [orders, pendingOrders];
}

class SparkOrdersError extends SparkOrdersState {
  final String message;

  SparkOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
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
