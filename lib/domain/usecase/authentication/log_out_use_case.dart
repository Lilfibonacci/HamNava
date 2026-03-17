import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exeption/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class LogOutUseCase {
  final IAuthenticationRepository repository;
  LogOutUseCase(this.repository);
  
  Future<Either<ApiExeption, void>> call() => repository.logOut();
}
