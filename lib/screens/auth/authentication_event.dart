part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginWithEmailAndPasswordEvent extends AuthenticationEvent {
  String email;
  String password;

  LoginWithEmailAndPasswordEvent({required this.email, required this.password});
}

class LoginWithFacebookEvent extends AuthenticationEvent {}

class LoginWithGoogleEvent extends AuthenticationEvent {}

class LoginWithAppleEvent extends AuthenticationEvent {}

class LoginWithPhoneNumberEvent extends AuthenticationEvent {
  auth.PhoneAuthCredential credential;
  String phoneNumber;
  String? fullName;
  Uint8List? imageData;

  LoginWithPhoneNumberEvent({
    required this.credential,
    required this.phoneNumber,
    this.fullName,
    this.imageData,
  });
}

class SignupWithEmailAndPasswordEvent extends AuthenticationEvent {
  String emailAddress;
  String password;
  Uint8List? imageData;

  String? fullName;

  SignupWithEmailAndPasswordEvent(
      {required this.emailAddress,
      required this.password,
      this.imageData,
      this.fullName = 'User'});
}

class LogoutEvent extends AuthenticationEvent {
  LogoutEvent();
}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}
