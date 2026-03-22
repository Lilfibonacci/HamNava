import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/repository/user_repository.dart';

class AddFriendUseCase {
  final IUserRepository repository;

  AddFriendUseCase(this.repository);

  Future<Either<ApiException, void>> call(String userId) {
    return repository.addFriend(userId);
  }
}
