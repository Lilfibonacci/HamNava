import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';

class CheckLoginStatusUseCase {
  final IAuthenticationRepository repository;
  CheckLoginStatusUseCase(this.repository);

  bool call() => repository.isLogedIn();
}
