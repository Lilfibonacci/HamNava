import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/user_dto.dart';
import 'package:pocketbase/pocketbase.dart';

class ConversationDto {
  final String id;
  final String name;
  final bool isGroup;
  final List<UserDto> admin;
  final List<UserDto> participants;
  final MessageDto? lastMessage;

  ConversationDto({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.admin,
    required this.participants,
    this.lastMessage,
  });

  factory ConversationDto.fromRecord(RecordModel record) {
    List<RecordModel> safeGetExpandList(String key) {
      try {
        return record.get<List<RecordModel>>('expand.$key');
      } catch (_) {
        return [];
      }
    }

    final participantsList = safeGetExpandList('participants');
    final adminList = safeGetExpandList('admin');

    MessageDto? lastMessageDto;
    try {
      final messageRecord = record.get<RecordModel>('expand.last_message');
      lastMessageDto = MessageDto.fromRecord(messageRecord);
    } catch (_) {
      try {
        final messageList = record.get<List<RecordModel>>(
          'expand.last_message',
        );
        if (messageList.isNotEmpty) {
          lastMessageDto = MessageDto.fromRecord(messageList.first);
        }
      } catch (_) {}
    }

    return ConversationDto(
      id: record.id,
      name: record.getStringValue('name'),
      isGroup: record.getBoolValue('is_group'),
      admin: adminList.map((e) => UserDto.fromRecord(e)).toList(),
      participants: participantsList.map((e) => UserDto.fromRecord(e)).toList(),
      lastMessage: lastMessageDto,
    );
  }
}
