import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateOrderRequestEvent extends OrderEvent {
  final OrderEntity order;

  CreateOrderRequestEvent({required this.order});

  @override
  List<Object?> get props => [order];
}
