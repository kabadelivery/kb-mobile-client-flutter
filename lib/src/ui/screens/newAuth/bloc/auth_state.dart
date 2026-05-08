
part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthOtpSent extends AuthState {
  final String message;
  final bool isRegister;

  AuthOtpSent({
    required this.message,
    required this.isRegister,
  });
}

final class AuthAuthenticated extends AuthState {
}

final class AuthRegistered extends AuthState {
  final String message;

  AuthRegistered({
    required this.message,
  });
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure({
    required this.message,
  });
}

final class ChangeIdentifierState extends AuthState{
  final bool isPhone;
  ChangeIdentifierState({required this.isPhone});
}
final class ClickAuthTypeState extends AuthState{
  final bool isLogin;
  ClickAuthTypeState({required this.isLogin});
}
final class OtpLoadingState extends AuthState{}
final class OtpSuccessState extends AuthState{}
final class RequiredOtpState extends AuthState{}
final class OtpFailureState extends AuthState{
  final String message;
  OtpFailureState({required this.message});
}
final class OtpInitialState extends AuthState{}
final class OtpTimerRunningState extends AuthState {
  final int secondsLeft;

  OtpTimerRunningState({required this.secondsLeft});
}

final class OtpTimerFinishedState extends AuthState {}
final class selectCodeCountryState extends AuthState{
  final String code;
  selectCodeCountryState({required this.code});
}