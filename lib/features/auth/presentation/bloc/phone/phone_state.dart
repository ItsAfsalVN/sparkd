part of 'phone_bloc.dart'; 


class PhoneState extends Equatable {
  final String phoneNumber;
  final bool isPhoneNumberValid;
  final FormStatus status;
  final String? errorMessage;

  const PhoneState({
    this.phoneNumber = '',
    this.isPhoneNumberValid = false, 
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  PhoneState copyWith({
    String? phoneNumber,
    bool? isPhoneNumberValid,
    FormStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PhoneState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneNumberValid: isPhoneNumberValid ?? this.isPhoneNumberValid,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber,
    isPhoneNumberValid,
    status,
    errorMessage,
  ];
}
