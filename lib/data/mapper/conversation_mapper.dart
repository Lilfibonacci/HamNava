import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/mapper/user_mapper.dart';
import 'package:flutter_chat_room_app/domain/entity/conversation_entity.dart';

class ConversationMapper {
  static ConversationEntity toDomain(ConversationDto dto) {
    return ConversationEntity(
      id: dto.id,
      name: dto.name.isEmpty ? null : dto.name,
      isGroup: dto.isGroup,
      admin: UserMapper.toDomainList(dto.admin),
      participants: UserMapper.toDomainList(dto.participants),
      lastMessage: dto.lastMessage?.text,
      // created: dto.lastMessage!.created,
    );
  }

  static List<ConversationEntity> toDomainList(
    List<ConversationDto> conversationDtoList,
  ) {
    return conversationDtoList
        .map((conversationDto) => toDomain(conversationDto))
        .toList();
  }
}
