import 'package:equatable/equatable.dart';

abstract class SparkOrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSparkOrdersEvent extends SparkOrdersEvent {
  final String sparkId;

  LoadSparkOrdersEvent({required this.sparkId});

  @override
  List<Object?> get props => [sparkId];
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
