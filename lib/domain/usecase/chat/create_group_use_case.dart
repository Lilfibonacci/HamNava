import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class CreateGroupUseCase {
  final IChatRepository repository;

  CreateGroupUseCase(this.repository);

  Future<Either<ApiException, ConversationEntity>> call(
    List<UserEntity> participantIds,
    String chatName,
  ) {
    return repository.createOrGetGroupChat(
      chatName: chatName,
      participantIds: participantIds,
    );
  }
}
