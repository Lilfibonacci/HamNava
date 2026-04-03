import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class GetProfileInfoUseCase {
  final IUserRepository repository;

  GetProfileInfoUseCase(this.repository);

  Future<Either<ApiException, UserEntity>> call(String currentUserId) {
    return repository.getProfileInfo(currentUserId);
  }
}
