part of 'phone_bloc.dart';

class PhoneState extends Equatable {
  final String phoneNumber;
  final bool isPhoneNumberValid;
  final FormStatus status;
  final String? errorMessage;
  final String? verificationId;
  final String smsCode;


  const PhoneState({
    this.phoneNumber = '',
    this.isPhoneNumberValid = false,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.verificationId,
    this.smsCode = ''
  });

  PhoneState copyWith({
    String? phoneNumber,
    bool? isPhoneNumberValid,
    FormStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? verificationId,
    bool clearVerificationId = false,
    String? smsCode
  }) {
    return PhoneState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneNumberValid: isPhoneNumberValid ?? this.isPhoneNumberValid,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      verificationId: clearVerificationId ? null : verificationId ?? this.verificationId,
      smsCode:  smsCode ?? this.smsCode
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber,
    isPhoneNumberValid,
    status,
    errorMessage,
    verificationId,
    smsCode
  ];
}
