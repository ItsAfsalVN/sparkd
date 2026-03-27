import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkshopLoadMessages extends WorkshopEvent {
  final String orderId;

  WorkshopLoadMessages({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class WorkshopSendMessage extends WorkshopEvent {
  final WorkshopMessageEntity message;

  WorkshopSendMessage({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopDeleteMessage extends WorkshopEvent {
  final String messageId;

  WorkshopDeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}
