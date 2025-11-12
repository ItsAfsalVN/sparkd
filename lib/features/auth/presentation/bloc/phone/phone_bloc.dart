import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/utils/logger.dart';
import 'package:sparkd/features/auth/domain/repositories/sign_up_data_repository.dart';
import 'package:sparkd/features/auth/domain/usecases/request_otp.dart';
import 'package:sparkd/features/auth/domain/usecases/verify_otp.dart';
import 'package:sparkd/features/auth/presentation/bloc/sign_up/sign_up_bloc.dart';

part 'phone_event.dart';
part 'phone_state.dart';

class PhoneBloc extends Bloc<PhoneEvent, PhoneState> {
  final SignUpDataRepository _signUpDataRepository;
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;

  SignUpDataRepository get signUpDataRepository => _signUpDataRepository;

  PhoneBloc({
    required SignUpDataRepository signUpDataRepository,
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
  }) : _signUpDataRepository = signUpDataRepository,
       _requestOtpUseCase = requestOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       super(_initialState(signUpDataRepository)) {
    // CHANGED: Load initial state from repository
    on<PhoneNumberChanged>(_onPhoneNumberChanged);
    on<PhoneNumberSubmitted>(_onPhoneNumberSubmitted);
    on<OtpCodeChanged>(_onOtpCodeChanged);
    on<OtpSubmitted>(_onOtpSubmitted);
    on<OtpSessionCancelled>(_onOtpSessionCancelled);
  }

  // NEW: Static method to create initial state from repository
  static PhoneState _initialState(SignUpDataRepository repository) {
    final savedData = repository.getData();

    // Handle nullable phone number with default empty string
    final phoneNumber = savedData.phoneNumber ?? '';

    // Validate the phone number
    final isPhoneNumberValid =
        phoneNumber.length == 10 && int.tryParse(phoneNumber) != null;

    // Determine initial form status
    final initialStatus = isPhoneNumberValid
        ? FormStatus.valid
        : FormStatus.invalid;

    return PhoneState(
      phoneNumber: phoneNumber,
      isPhoneNumberValid: isPhoneNumberValid,
      status: initialStatus,
      smsCode: '',
      verificationId: null,
      errorMessage: null,
    );
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
  ) async {
    if (state.isPhoneNumberValid) {
      if (!isClosed && state.isPhoneNumberValid) {
        emit(state.copyWith(status: FormStatus.submitting));
        try {
          final verificationID = await _requestOtpUseCase(state.phoneNumber);
          if (!isClosed) {
            emit(
              state.copyWith(
                status: FormStatus.otpSent,
                verificationId: verificationID,
              ),
            );
            logger.i("PhoneBloc: OTP Sent. Verification ID: $verificationID");
          }
        } catch (error) {
          logger.e("PhoneBloc: Error requesting OTP: $error");
          if (!isClosed) {
            emit(
              state.copyWith(
                status: FormStatus.failure,
                errorMessage: error is Exception
                    ? error.toString()
                    : 'Failed to send OTP. Please try again.',
                clearVerificationId: true,
              ),
            );
          }
        }
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

  void _onOtpCodeChanged(OtpCodeChanged event, Emitter<PhoneState> emit) {
    final smsCode = event.smsCode;
    final isValid = smsCode.length == 6;

    emit(
      state.copyWith(
        smsCode: smsCode,
        status:
            state.status == FormStatus.otpSent ||
                state.status == FormStatus.failure
            ? (isValid ? FormStatus.otpSent : FormStatus.invalid)
            : state.status,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<PhoneState> emit,
  ) async {
    logger.t(
      "PhoneBloc: OtpSubmitted - smsCode: '${state.smsCode}' (len: ${state.smsCode.length}), "
      "verificationId: ${state.verificationId != null ? 'present' : 'null'}, "
      "status: ${state.status}",
    );

    if (state.smsCode.length != 6) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage: 'Please enter a 6-digit OTP.',
        ),
      );
      return;
    }

    if (state.verificationId == null) {
      emit(
        state.copyWith(
          status: FormStatus.failure,
          errorMessage:
              'Verification session expired. Please request OTP again.',
        ),
      );
      return;
    }

    // Prevent double submission
    if (state.status == FormStatus.submitting) {
      logger.i("PhoneBloc: Already submitting, ignoring duplicate submission");
      return;
    }

    emit(state.copyWith(status: FormStatus.submitting));

    try {
      // Call the VerifyOtpUseCase
      await _verifyOtpUseCase(
        verificationId: state.verificationId!,
        smsCode: state.smsCode,
      );

      final currentData = _signUpDataRepository.getData();
      _signUpDataRepository.updateData(
        currentData.copyWith(
          verificationID: state.verificationId,
          smsCode: state.smsCode,
        ),
      );
      
      logger.i("Phone bloc : Verification ID and smsCode stored to prefs");

      // OTP Verified Successfully!
      if (!isClosed) {
        logger.i("PhoneBloc: OTP Verified.");
        emit(state.copyWith(status: FormStatus.success));
      }
    } catch (e) {
      // OTP Verification Failed
      logger.e("PhoneBloc: Error verifying OTP: $e");
      if (!isClosed) {
        emit(
          state.copyWith(
            status: FormStatus.failure,
            errorMessage: 'Invalid OTP. Please try again.',
          ),
        );
      }
    }
  }

  void _onOtpSessionCancelled(
    OtpSessionCancelled event,
    Emitter<PhoneState> emit,
  ) {
    emit(
      state.copyWith(
        status: FormStatus.valid,
        clearVerificationId: true,
        clearErrorMessage: true,
      ),
    );
    logger.i("PhoneBloc: OTP Session canceled. State reset.");
  }
}
