import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';

part 'sme_order_event.dart';
part 'sme_order_state.dart';

class SmeOrderBloc extends Bloc<SmeOrderEvent, SmeOrderState> {
  SmeOrderBloc() : super(SmeOrderBlocInitial()) {
    on<SmeOrderEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
