part of 'phone_bloc.dart';

sealed class PhoneEvent extends Equatable {
  const PhoneEvent();

  @override
  List<Object> get props => [];
}

class PhoneNumberChanged extends PhoneEvent {
  final String phoneNumber;

  const PhoneNumberChanged({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class PhoneNumberSubmitted extends PhoneEvent {}

class OtpCodeChanged extends PhoneEvent {
  final String smsCode;
  const OtpCodeChanged({required this.smsCode});
  @override
  List<Object> get props => [smsCode];
}

class OtpSubmitted extends PhoneEvent {
  const OtpSubmitted();
}


class OtpSessionCancelled extends PhoneEvent {}