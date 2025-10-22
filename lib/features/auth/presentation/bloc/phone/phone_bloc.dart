import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';

part 'phone_event.dart';
part 'phone_state.dart';

class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  final SignUpDataRepository _signUpDataRepository;

  PhoneBloc({required SignUpDataRepository signUpDataRepository})
    : _signUpDataRepository = signUpDataRepository,
      super(const PhoneState()) {
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
  }

  void _onPhoneNumberChanged(
    PhoneNumberChanged event,
    Emitter<PhoneState> emit,
  ) {
    final phoneNumber = event.phoneNumber;
    final isValid =
        phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;

    emit(
      state.copyWith(
        phoneNumber: phoneNumber,
        isPhoneNumberValid: isValid,
        status: isValid ? FormStatus.valid : FormStatus.invalid,
        clearErrorMessage: true,
      ),
    );

    if (isValid) {
      final currentData = _signUpDataRepository.getData();
      _signUpDataRepository.updateData(
        currentData.copyWith(phoneNumber: phoneNumber),
      );
    }
  }

  void _onPhoneNumberSubmitted(
    PhoneNumberSubmitted event,
    Emitter<PhoneState> emit,
  ){
    if (state.isPhoneNumberValid) {
      if (!isClosed && state.isPhoneNumberValid) {
        emit(state.copyWith(status: FormStatus.submitting));
        if (!isClosed) emit(state.copyWith(status: FormStatus.success));
      }
    } else {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: 'Invalid phone number',
        ),
      );
    }
  }
} 
