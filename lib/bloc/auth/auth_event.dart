import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String phoneNumber;
  final String password;
  final String confirmPassword;

  const RegisterEvent({
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [email, password, phoneNumber];
}
