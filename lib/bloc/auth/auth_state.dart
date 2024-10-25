import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> user;

  const AuthSuccess({
    required this.user,
  });
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}
