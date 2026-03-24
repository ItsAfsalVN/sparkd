part of 'sme_order_bloc.dart';

abstract class SmeOrderState extends Equatable {
  const SmeOrderState();

  @override
  List<Object?> get props => [];
}

class SmeOrderBlocInitial extends SmeOrderState {}

class SmeOrderBlocLoading extends SmeOrderState {
  final String? currentStatus;

  const SmeOrderBlocLoading({this.currentStatus});

  @override
  List<Object?> get props => [currentStatus];
}

class SmeOrderBlocLoaded extends SmeOrderState {
  final List<OrderEntity> orders;
  final String? currentStatus;

  const SmeOrderBlocLoaded({required this.orders, this.currentStatus});

  @override
  List<Object?> get props => [orders, currentStatus];
}

class SmeOrderBlocError extends SmeOrderState {
  final String message;
  final String? currentStatus;

  const SmeOrderBlocError({required this.message, this.currentStatus});

  @override
  List<Object?> get props => [message, currentStatus];
}
