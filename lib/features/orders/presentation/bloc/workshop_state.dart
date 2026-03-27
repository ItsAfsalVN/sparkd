import 'package:equatable/equatable.dart';
import 'package:sparkd/features/orders/domain/entities/workshop_message_entity.dart';

abstract class WorkshopState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopLoaded extends WorkshopState {
  final List<WorkshopMessageEntity> messages;

  WorkshopLoaded({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class WorkshopError extends WorkshopState {
  final String message;

  WorkshopError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopMessageSending extends WorkshopState {}

class WorkshopMessageSent extends WorkshopState {
  final WorkshopMessageEntity message;

  WorkshopMessageSent({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkshopMessageSentError extends WorkshopState {
  final String message;

  WorkshopMessageSentError({required this.message});

  @override
  List<Object?> get props => [message];
}
