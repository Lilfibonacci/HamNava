import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class IsLogedinUseCase {
  final IAuthenticationReopsitory repository;

  IsLogedinUseCase(this.repository);

  bool call() {
    return repository.isLogedIn();
  }
}
