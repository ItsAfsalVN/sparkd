part of 'sme_order_bloc_bloc.dart';

sealed class SmeOrderBlocState extends Equatable {
  const SmeOrderBlocState();
  
  @override
  List<Object> get props => [];
}

final class SmeOrderBlocInitial extends SmeOrderBlocState {}
