import 'dart:async';
import 'dart:io';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:pocketbase/pocketbase.dart';

class ChatRemoteDataSourceImpl implements IChatDatasource {
  final PocketBase pb;
  ChatRemoteDataSourceImpl(this.pb);

  //----------------- chat -----------------

  @override
  Future<ConversationDto> createOrGetGroupChat({
    required String chatName,
    required List<String> participantIds,
  }) async {
    try {
      final myUserId =
          locator.get<PocketBaseConfig>().client.authStore.record?.id ?? '';

      final List<String> finalParticipants = List.from(participantIds);
      if (!finalParticipants.contains(myUserId)) {
        finalParticipants.add(myUserId);
      }

      final body = <String, dynamic>{
        "name": chatName,
        "is_group": true,
        "participants": finalParticipants,
        "admin": [myUserId],
      };

      final record = await pb
          .collection('chat')
          .create(body: body, expand: 'participants,admin');

      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('مشکلی در ساخت گروه پیش آمده است');
    }
  }

  @override
  Future<ConversationDto> createOrGetPrivateChat(String targetUserId) async {
    try {
      final currentUserId =
          locator.get<PocketBaseConfig>().client.authStore.record?.id ?? '';

      final filter =
          'is_group = false && participants ~ "$currentUserId" && participants ~ "$targetUserId"';

      //create chat
      final existingChats = await pb
          .collection('chat')
          .getList(filter: filter, expand: 'participants');

      if (existingChats.items.isNotEmpty) {
        return ConversationDto.fromRecord(existingChats.items.first);
      }

      //new chat
      final body = <String, dynamic>{
        "name": "",
        "is_group": false,
        "participants": [currentUserId, targetUserId],
      };

      final record = await pb
          .collection('chat')
          .create(body: body, expand: 'participants');
      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('مشکلی در ایجاد گفتگو با کاربر پیش آمده است');
    }
  }

  @override
  Future<void> deleteChat(String chatId) async {
    try {
      await pb.collection('chat').delete(chatId);
    } catch (e) {
      throw ApiException('مشکلی در حذف چت به وجود آمده است');
    }
  }

  @override
  Future<void> deleteMessage(String messageId, String chatId) async {
    try {
      await pb.collection('messages').delete(messageId);

      final result = await pb
          .collection('messages')
          .getList(
            page: 1,
            perPage: 1,
            filter: 'chat_id = "$chatId"',
            sort: '-created',
          );

      if (result.items.isNotEmpty) {
        final newLastMessageId = result.items.first.id;
        await pb
            .collection('chat')
            .update(chatId, body: {'last_message': newLastMessageId});
      } else {
        await pb
            .collection('chat')
            .update(chatId, body: {'last_message': null});
      }
    } catch (e) {
      throw Exception('خطا در حذف پیام و بروزرسانی چت');
    }
  }

  @override
  Future<MessageDto> editMessage({
    required String messageId,
    required String newText,
  }) async {
    try {
      final record = await pb
          .collection('messages')
          .update(messageId, body: {'text': newText});
      return MessageDto.fromRecord(record);
    } catch (e) {
      throw ApiException('خطا در ویرایش پیام');
    }
  }

  @override
  Future<List<ConversationDto>> getAllChats() async {
    try {
      final myUserId =
          locator.get<PocketBaseConfig>().client.authStore.record?.id ?? '';

      final resultList = await pb
          .collection('chat')
          .getList(
            page: 1,
            perPage: 50,
            sort: '-updated',
            expand: 'participants,last_message,last_message.sender_id,admin',
            filter: 'participants ~ "$myUserId"',
          );

      final List<ConversationDto> conversations = [];
      for (final record in resultList.items) {
        ConversationDto dto = ConversationDto.fromRecord(record);

        // Try to decrypt last message text for home screen preview
        if (dto.lastMessage != null && dto.lastMessage!.text.isNotEmpty) {
          try {
            RecordModel? lastMsgRecord;
            try {
              lastMsgRecord = record.get<RecordModel>('expand.last_message');
            } catch (_) {
              try {
                final lastMsgList = record.get<List<RecordModel>>('expand.last_message');
                if (lastMsgList.isNotEmpty) lastMsgRecord = lastMsgList.first;
              } catch (_) {}
            }

            if (lastMsgRecord != null) {
              final decryptedMsgDto = await _decryptMessageRecord(lastMsgRecord);
              dto = ConversationDto(
                id: dto.id,
                name: dto.name,
                isGroup: dto.isGroup,
                admin: dto.admin,
                participants: dto.participants,
                lastMessage: decryptedMsgDto,
              );
            }
          } catch (_) {
            // Decryption failed, use as-is
          }
        }

        conversations.add(dto);
      }
      return conversations;
    } catch (e) {
      throw ApiException("مشکلی در دریافت چت‌ها به وجود آمده است");
    }
  }

  Future<MessageDto> _decryptMessageRecord(RecordModel record) async {
    try {
      final textStr = record.getStringValue('text');

      MessageDto? replyToDto;
      if (record.expand.containsKey('reply_to')) {
        final replyObj = record.expand['reply_to'];
        if (replyObj != null && replyObj.isNotEmpty) {
          final replyRecord = replyObj.first as RecordModel;
          replyToDto = await _decryptMessageRecord(replyRecord);
        }
      }

      return MessageDto.fromRecord(
        record,
        decryptedText: textStr.isEmpty ? null : textStr,
        decryptedReplyTo: replyToDto,
      );
    } catch (e) {
      return MessageDto.fromRecord(record);
    }
  }

  //----------------- messages -----------------
  @override
  Future<List<MessageDto>> getMessages(String chatId, {int page = 1}) async {
    try {
      final result = await pb
          .collection('messages')
          .getList(
            perPage: 30,
            page: page,
            filter: 'chat_id = "$chatId"',
            sort: '-created',
            expand: 'sender_id,reply_to',
          );

      final List<MessageDto> dtos = [];
      for (var record in result.items) {
        dtos.add(await _decryptMessageRecord(record));
      }
      return dtos;
    } catch (e) {
      throw ApiException("خطا در بارگذاری پیام‌ها");
    }
  }

  @override
  Stream<({String action, MessageDto message})> listenToMessages(
    String chatId,
  ) {
    final controller =
        StreamController<({String action, MessageDto message})>();

    pb.collection('messages').subscribe('*', (e) async {
      if (e.record != null && e.record!.getStringValue('chat_id') == chatId) {
        final decryptedDto = await _decryptMessageRecord(e.record!);
        controller.add((action: e.action, message: decryptedDto));
      }
    }, expand: 'sender_id,reply_to');

    controller.onCancel = () {
      pb.collection('messages').unsubscribe('*');
      controller.close();
    };

    return controller.stream;
  }

  bool _isMedia(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  @override
  Future<MessageDto> sendMessage({
    required String chatId,
    String? text,
    String? replyId,
    dynamic attachment,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final myUserId = pb.authStore.record?.id;
      if (myUserId == null) throw ApiException('کاربر یافت نشد');

      dio.MultipartFile? uploadMultipartFile;
      dio.MultipartFile? uploadAttachmentFile;
      String? attachmentFileName;
      bool isMediaUnencrypted = false;

      if (attachment != null) {
        String fileName = '';
        List<int> fileBytes = [];

        try {
          if (attachment is File) {
            fileName = attachment.path.split('/').last;
            fileBytes = await attachment.readAsBytes();
          } else {
            // Assume it's a PlatformFile or XFile
            fileName = attachment.name;
            try {
              fileBytes = await attachment.readAsBytes();
            } catch (_) {
              if (attachment.bytes != null) {
                fileBytes = attachment.bytes!;
              }
            }
          }
        } catch (_) {}

        attachmentFileName = fileName;
        isMediaUnencrypted = fileName.isNotEmpty && _isMedia(fileName);

        uploadMultipartFile = dio.MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
        uploadAttachmentFile = dio.MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
      }

      final formDataMap = <String, dynamic>{
        "chat_id": chatId,
        "sender_id": myUserId,
        "text": text ?? '',
      };

      if (replyId != null) formDataMap["reply_to"] = replyId;

      if (uploadMultipartFile != null) {
        formDataMap["file"] = uploadMultipartFile;
        formDataMap["attachment"] = uploadAttachmentFile;
      }

      
      final formData = dio.FormData.fromMap(formDataMap);

      final dioClient = dio.Dio();
      final url = '${pb.baseUrl}/api/collections/messages/records?expand=sender_id,reply_to';
      final response = await dioClient.post(
        url,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': pb.authStore.token,
          },
        ),
        onSendProgress: onSendProgress,
      );

      final record = RecordModel(response.data);

      await pb
          .collection('chat')
          .update(chatId, body: {'last_message': record.id});

      return MessageDto.fromRecord(record, isUnencrypted: isMediaUnencrypted);
    } catch (e) {
      throw ApiException('پیام ارسال نشد');
    }
  }

  @override
  Future<ConversationDto> addFriendToGroup(String userId, String chatId) async {
    try {
      final body = {'participants+': userId};

      final record = await pb
          .collection('chat')
          .update(chatId, body: body, expand: 'participants');
      return ConversationDto.fromRecord(record);
    } catch (e) {
      throw ApiException('خطا در افزودن عضو به گروه');
    }
  }

  @override
  Future<void> leaveFromGroup(String userId, String chatId) async {
    try {
      final body = {'participants-': userId};

      await pb.collection('chat').update(chatId, body: body);
    } catch (e) {
      throw ApiException('خطا در ترک کردن گروه');
    }
  }
}
