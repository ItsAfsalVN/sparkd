import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderCreating extends OrderState {}

class OrderCreated extends OrderState {
  final String orderId;

  OrderCreated({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;

  OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
