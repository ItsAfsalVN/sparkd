part of 'sme_order_bloc.dart';

abstract class SmeOrderState extends Equatable {
  const SmeOrderState();
  
  @override
  List<Object> get props => [];
}

class SmeOrderBlocInitial extends SmeOrderState {}

class SmeOrderBlocLoading extends SmeOrderState {}

class SmeOrderBlocLoaded extends SmeOrderState {
  final List<OrderEntity> orders;

  const SmeOrderBlocLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class SmeOrderBlocError extends SmeOrderState {
  final String message;

  const SmeOrderBlocError({required this.message});

  @override
  List<Object> get props => [message];
}