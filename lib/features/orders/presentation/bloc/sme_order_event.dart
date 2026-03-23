part of 'sme_order_bloc.dart';

abstract class SmeOrderEvent extends Equatable {
  const SmeOrderEvent();

  @override
  List<Object> get props => [];
}

class SmeOrdersRequested extends SmeOrderEvent {
  final String smeId;

  const SmeOrdersRequested({required this.smeId});

  @override
  List<Object> get props => [smeId];
}

class SmeOrderStatusFilterChanged extends SmeOrderEvent {
  final String status;

  const SmeOrderStatusFilterChanged({required this.status});

  @override
  List<Object> get props => [status];
}

class SmeOrderSortOptionChanged extends SmeOrderEvent {
  final String sortOption;

  const SmeOrderSortOptionChanged({required this.sortOption});

  @override
  List<Object> get props => [sortOption];
}

class SmeOrderRefreshRequested extends SmeOrderEvent {
  final String smeId;

  const SmeOrderRefreshRequested({required this.smeId});

  @override
  List<Object> get props => [smeId];
}
