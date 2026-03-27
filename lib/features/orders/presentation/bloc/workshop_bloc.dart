import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/orders/domain/usecases/workshop_usecases.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_state.dart';

class WorkshopBloc extends Bloc<WorkshopEvent, WorkshopState> {
  final GetWorkshopMessagesUseCase _getMessagesUseCase;
  final SendWorkshopMessageUseCase _sendMessageUseCase;
  final DeleteWorkshopMessageUseCase _deleteMessageUseCase;

  WorkshopBloc({
    required GetWorkshopMessagesUseCase getMessagesUseCase,
    required SendWorkshopMessageUseCase sendMessageUseCase,
    required DeleteWorkshopMessageUseCase deleteMessageUseCase,
  }) : _getMessagesUseCase = getMessagesUseCase,
       _sendMessageUseCase = sendMessageUseCase,
       _deleteMessageUseCase = deleteMessageUseCase,
       super(WorkshopInitial()) {
    on<WorkshopLoadMessages>(_onLoadMessages);
    on<WorkshopSendMessage>(_onSendMessage);
    on<WorkshopDeleteMessage>(_onDeleteMessage);
  }

  Future<void> _onLoadMessages(
    WorkshopLoadMessages event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      emit(WorkshopLoading());
      await emit.forEach(
        _getMessagesUseCase(event.orderId),
        onData: (messages) => WorkshopLoaded(messages: messages),
        onError: (error, stackTrace) {
          logger.e('Error loading messages: $error');
          return WorkshopError(message: error.toString());
        },
      );
    } catch (e) {
      logger.e('Error in _onLoadMessages: $e');
      emit(WorkshopError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    WorkshopSendMessage event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      emit(WorkshopMessageSending());
      await _sendMessageUseCase(event.message);
      emit(WorkshopMessageSent(message: event.message));
    } catch (e) {
      logger.e('Error sending message: $e');
      emit(WorkshopMessageSentError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMessage(
    WorkshopDeleteMessage event,
    Emitter<WorkshopState> emit,
  ) async {
    try {
      await _deleteMessageUseCase(event.messageId);
    } catch (e) {
      logger.e('Error deleting message: $e');
      emit(WorkshopError(message: e.toString()));
    }
  }
}
