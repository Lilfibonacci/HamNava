import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class UpdateProfileUseCase {
  final IUserRepository repository;
  UpdateProfileUseCase(this.repository);

  Future<Either<ApiException, void>> call(
    String userId,
    String userName,
    String email,
    String name, {
    dynamic avatarFile,
  }) {
    return repository.updateProfile(
      userId: userId,
      name: name,
      email: email,
      userName: userName,
      avatarFile: avatarFile,
    );
  }
}
