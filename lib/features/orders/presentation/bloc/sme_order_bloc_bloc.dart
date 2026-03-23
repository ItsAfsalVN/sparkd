import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sme_order_bloc_event.dart';
part 'sme_order_bloc_state.dart';

class SmeOrderBlocBloc extends Bloc<SmeOrderBlocEvent, SmeOrderBlocState> {
  SmeOrderBlocBloc() : super(SmeOrderBlocInitial()) {
    on<SmeOrderBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
