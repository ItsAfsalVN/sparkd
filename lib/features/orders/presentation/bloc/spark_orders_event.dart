import 'package:equatable/equatable.dart';

abstract class SparkOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSparkOrdersEvent extends SparkOrdersEvent {
  final String sparkId;
  final String? status; // null for "All", or specific status string

  LoadSparkOrdersEvent({required this.sparkId, this.status});

  @override
  List<Object?> get props => [sparkId, status];
}

class SparkOrderStatusFilterChanged extends SparkOrdersEvent {
  final String? status; // null for "All", or specific status string

  SparkOrderStatusFilterChanged({this.status});

  @override
  List<Object?> get props => [status];
}

class AcceptOrderEvent extends SparkOrdersEvent {
  final String orderId;

  AcceptOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class RejectOrderEvent extends SparkOrdersEvent {
  final String orderId;
  final String reason;

  RejectOrderEvent({required this.orderId, required this.reason});

  @override
  List<Object?> get props => [orderId, reason];
}
