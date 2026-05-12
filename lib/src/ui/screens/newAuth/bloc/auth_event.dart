part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthReset extends AuthEvent {}

final class RequestLoginOtp extends AuthEvent {
  final String identifier;
  final String? countryCode;
  final bool isPhone;

  RequestLoginOtp({
    required this.identifier,
    required this.isPhone,
    this.countryCode,
  });
}

final class VerifyLoginOtp extends AuthEvent {
  final String identifier;
  final String otp;
  final bool isPhone;
  final String? countryCode;

  VerifyLoginOtp({
    required this.identifier,
    required this.otp,
    required this.isPhone,
    this.countryCode,
  });
}

final class RequestRegisterOtp extends AuthEvent {
  final String fullName;
  final String identifier;
  final String password;
  final bool isPhone;
  final String? countryCode;

  RequestRegisterOtp({
    required this.fullName,
    required this.identifier,
    required this.password,
    required this.isPhone,
    this.countryCode,
  });
}

final class ConfirmRegister extends AuthEvent {
  final String fullName;
  final String identifier;
  final String password;
  final String otp;
  final bool isPhone;
  final String? countryCode;

  ConfirmRegister({
    required this.fullName,
    required this.identifier,
    required this.password,
    required this.otp,
    required this.isPhone,
    this.countryCode,
  });


}

final class ChangeIdentifier extends AuthEvent{
  final bool isPhone;
  ChangeIdentifier({required this.isPhone});
}
final class LoadingEvent extends AuthEvent{}

final class ClickAuthTypeEvent extends AuthEvent{
  final bool isLogin;
  ClickAuthTypeEvent({required this.isLogin});
}
final class onPasswordRecoveryOtpEvent extends AuthEvent{
  final String otp;
  onPasswordRecoveryOtpEvent({required this.otp});
}
final class onLoginOtpEvent extends AuthEvent{
  final String otp;
  onLoginOtpEvent({required this.otp});
}
final class onSignupOtpEvent extends AuthEvent{
  final String otp;
  onSignupOtpEvent({required this.otp});
}

final class onSendPasswordRecoveryOtpEvent extends AuthEvent {
  final String login;

  onSendPasswordRecoveryOtpEvent({
    required this.login,
  });
}

final class onSendLoginOtpEvent extends AuthEvent{
  final String login;
  final String password;
  final String app_version;
  final bool shouldSendOtp;
  onSendLoginOtpEvent({required this.login,required this.password,required this.app_version,required this.shouldSendOtp});
}
final class selectCodeCountryEvent extends AuthEvent{
  final String code;
  selectCodeCountryEvent({required this.code});
}
final class onSendSignupOtpEvent extends AuthEvent{
}
final class OtpInitEvent extends AuthEvent{}
class StartOtpTimerEvent extends AuthEvent {}

class TickOtpTimerEvent extends AuthEvent {}
class UpdateUsername extends AuthEvent{
  final String text;
  UpdateUsername({required this.text});
}
class UpdateEmail extends AuthEvent{
  final String text;
  UpdateEmail({required this.text});
}
class UpdatePhone extends AuthEvent{
  final String text;
  UpdatePhone({required this.text});
}
class UpdatePassword extends AuthEvent{
  final String text;
  UpdatePassword({required this.text});
}
class StopOtpTimerEvent extends AuthEvent {}

final class SendPasswordRecoveryOtpEvent extends AuthEvent {
  final String login;

  SendPasswordRecoveryOtpEvent({required this.login});
}

final class VerifyPasswordRecoveryOtpEvent extends AuthEvent {
  final String otp;

  VerifyPasswordRecoveryOtpEvent({required this.otp});
}

final class ResetPasswordEvent extends AuthEvent {
  final String login;
  final String password;

  ResetPasswordEvent({
    required this.login,
    required this.password,
  });
}