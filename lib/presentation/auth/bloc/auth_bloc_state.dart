import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String name;
  final String email;
  final String role;

  AuthAuthenticated({required this.name, required this.email, required this.role});

  @override
  List<Object?> get props => [name, email, role];
}

class AuthRegisterSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
