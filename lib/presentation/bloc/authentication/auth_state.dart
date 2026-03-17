import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Either<ApiExeption, void> result;

  AuthSuccess(this.result);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
