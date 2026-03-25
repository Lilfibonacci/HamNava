import 'package:flutter_chat_room_app/domain/entity/message_entity.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_repository.dart';

class ListenToMessageUseCase {
  final IChatRepository repository;
  ListenToMessageUseCase(this.repository);

  Stream<({String action, MessageEntity message})> call(String chatId) {
    return repository.listenToMessages(chatId);
  }
}
