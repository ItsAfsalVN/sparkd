part of 'sme_order_bloc.dart';

abstract class SmeOrderEvent extends Equatable {
  const SmeOrderEvent();

  @override
  List<Object?> get props => [];
}

class SmeOrdersRequested extends SmeOrderEvent {
  final String smeId;
  final String? status; // null for "All", or specific status string

  const SmeOrdersRequested({required this.smeId, this.status});

  @override
  List<Object?> get props => [smeId, status];
}

class SmeOrderStatusFilterChanged extends SmeOrderEvent {
  final String? status; // null for "All", or specific status string

  const SmeOrderStatusFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}

class SmeOrderSortOptionChanged extends SmeOrderEvent {
  final String sortOption;

  const SmeOrderSortOptionChanged({required this.sortOption});

  @override
  List<Object> get props => [sortOption];
}

class SmeOrderRefreshRequested extends SmeOrderEvent {
  final String smeId;
  final String? status; // null for "All", or specific status string

  const SmeOrderRefreshRequested({required this.smeId, this.status});

  @override
  List<Object?> get props => [smeId, status];
}

class MarkOrderAsPaidEvent extends SmeOrderEvent {
  final String orderId;
  final int deliveryTimeInDays;

  const MarkOrderAsPaidEvent({
    required this.orderId,
    required this.deliveryTimeInDays,
  });

  @override
  List<Object> get props => [orderId, deliveryTimeInDays];
}
