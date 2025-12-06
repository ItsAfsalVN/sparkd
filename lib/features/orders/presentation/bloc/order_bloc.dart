import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/orders/domain/usecases/create_order_request.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/order_state.dart';
import 'package:sparkd/core/services/notification_service.dart';
import 'package:logger/logger.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderRequestUseCase _createOrderRequestUseCase;
  final NotificationService _notificationService;
  final Logger _logger = Logger();

  OrderBloc({
    required CreateOrderRequestUseCase createOrderRequestUseCase,
    required NotificationService notificationService,
  }) : _createOrderRequestUseCase = createOrderRequestUseCase,
       _notificationService = notificationService,
       super(OrderInitial()) {
    on<CreateOrderRequestEvent>(_onCreateOrderRequest);
  }

  Future<void> _onCreateOrderRequest(
    CreateOrderRequestEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderCreating());
    try {
      _logger.i('Creating order request: ${event.order.gigTitle}');

      final orderId = await _createOrderRequestUseCase(event.order);

      _logger.i('Order request created with ID: $orderId');

      // Send notification to Spark
      await _notificationService.sendNotificationToUser(
        userId: event.order.sparkID,
        title: 'New Order Request!',
        body: '${event.order.gigTitle} - ₹${event.order.gigPrice}',
        data: {
          'type': 'new_order',
          'orderId': orderId,
          'gigId': event.order.gigID,
        },
      );

      emit(OrderCreated(orderId: orderId));
    } catch (e) {
      _logger.e('Error creating order: $e');
      emit(OrderError(message: e.toString()));
    }
  }
}
