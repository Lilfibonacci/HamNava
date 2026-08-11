import 'dart:async';
import 'dart:io';
import 'package:flutter_chat_room_app/core/di/di.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/core/network/pocket_base_config.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dtos/conversation_dto.dart';
import 'package:flutter_chat_room_app/data/dtos/message_dto.dart';
import 'dart:convert';
import 'package:flutter_chat_room_app/core/encryption/encryption_service.dart';
import 'package:flutter_chat_room_app/core/encryption/key_manager.dart';
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
        final dto = ConversationDto.fromRecord(record);

        // Try to decrypt last message text for home screen preview
        if (dto.lastMessage != null && dto.lastMessage!.text.isNotEmpty) {
          try {
            final parsed =
                jsonDecode(dto.lastMessage!.text) as Map<String, dynamic>;
            final encText = parsed['e'] as String?;
            final keysMap = parsed['k'] as Map<String, dynamic>?;

            if (encText != null && keysMap != null) {
              final encryptionService = locator<EncryptionService>();
              final keyManager = locator<KeyManager>();
              final myKeyPair = keyManager.myKeyPair;

              if (myKeyPair != null) {
                final encMsgKeyBase64 = keysMap[myUserId];
                if (encMsgKeyBase64 != null) {
                  // Get sender's public key from the expanded last_message.sender_id
                  String? senderPublicKey;
                  try {
                    final lastMsgRecord = record.get<RecordModel>(
                      'expand.last_message',
                    );
                    final senderRecord = lastMsgRecord.get<RecordModel>(
                      'expand.sender_id',
                    );
                    senderPublicKey =
                        senderRecord.data['public_key'] as String?;
                  } catch (_) {
                    try {
                      final lastMsgList = record.get<List<RecordModel>>(
                        'expand.last_message',
                      );
                      if (lastMsgList.isNotEmpty) {
                        final senderRecord = lastMsgList.first.get<RecordModel>(
                          'expand.sender_id',
                        );
                        senderPublicKey =
                            senderRecord.data['public_key'] as String?;
                      }
                    } catch (_) {}
                  }

                  if (senderPublicKey != null && senderPublicKey.isNotEmpty) {
                    final sharedSecret = await encryptionService
                        .deriveSharedSecret(myKeyPair, senderPublicKey);
                    final messageKey = await encryptionService
                        .decryptSymmetricKey(encMsgKeyBase64, sharedSecret);

                    if (messageKey != null) {
                      final decryptedText = await encryptionService.decryptText(
                        encText,
                        messageKey,
                      );
                      // Create a new ConversationDto with decrypted lastMessage
                      final decryptedMsgDto = MessageDto(
                        id: dto.lastMessage!.id,
                        text: decryptedText,
                        senderId: dto.lastMessage!.senderId,
                        sender: dto.lastMessage!.sender,
                        chatId: dto.lastMessage!.chatId,
                        attachment: dto.lastMessage!.attachment,
                        created: dto.lastMessage!.created,
                        replyTo: dto.lastMessage!.replyTo,
                      );
                      conversations.add(
                        ConversationDto(
                          id: dto.id,
                          name: dto.name,
                          isGroup: dto.isGroup,
                          admin: dto.admin,
                          participants: dto.participants,
                          lastMessage: decryptedMsgDto,
                        ),
                      );
                      continue;
                    }
                  }
                }
              }
            }
          } catch (_) {
            // Not JSON or decryption failed, use as-is
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
      final textJsonStr = record.getStringValue('text');
      if (textJsonStr.isEmpty) return MessageDto.fromRecord(record);

      final parsed = jsonDecode(textJsonStr) as Map<String, dynamic>;
      final encText = parsed['e'] as String?;
      final keysMap = parsed['k'] as Map<String, dynamic>?;

      if (keysMap == null) return MessageDto.fromRecord(record);

      final encryptionService = locator<EncryptionService>();
      final keyManager = locator<KeyManager>();

      final myKeyPair = keyManager.myKeyPair;
      if (myKeyPair == null) return MessageDto.fromRecord(record);

      final myUserId = pb.authStore.record?.id;
      final encMsgKeyBase64 = keysMap[myUserId];

      if (encMsgKeyBase64 == null) return MessageDto.fromRecord(record);

      final senderRecord = record.get<RecordModel>('expand.sender_id');
      final senderPublicKey = senderRecord.data['public_key'] as String?;
      if (senderPublicKey == null || senderPublicKey.isEmpty)
        return MessageDto.fromRecord(record);

      final sharedSecret = await encryptionService.deriveSharedSecret(
        myKeyPair,
        senderPublicKey,
      );
      final messageKey = await encryptionService.decryptSymmetricKey(
        encMsgKeyBase64,
        sharedSecret,
      );

      if (messageKey == null) return MessageDto.fromRecord(record);

      String decryptedText = '';
      if (encText != null && encText.isNotEmpty) {
        decryptedText = await encryptionService.decryptText(
          encText,
          messageKey,
        );
      }

      final messageKeyBytes = await messageKey.extractBytes();
      final bool isUnencrypted = parsed['u'] == true;

      return MessageDto.fromRecord(
        record,
        decryptedText: decryptedText,
        keyBytes: messageKeyBytes,
        isUnencrypted: isUnencrypted,
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
    File? attachment,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final encryptionService = locator<EncryptionService>();
      final keyManager = locator<KeyManager>();

      final myKeyPair = keyManager.myKeyPair;
      if (myKeyPair == null)
        throw ApiException('کلید رمزنگاری یافت نشد. لطفا مجدد وارد شوید.');

      final myUserId = pb.authStore.record?.id;

      // Fetch chat to get participants
      final chatRecord = await pb
          .collection('chat')
          .getOne(chatId, expand: 'participants');
      final participants = chatRecord.get<List<RecordModel>>(
        'expand.participants',
      );

      // Generate MessageKey
      final messageKey = await encryptionService.generateRandomSymmetricKey();

      // Encrypt keys for all participants
      final keysMap = <String, String>{};
      for (var p in participants) {
        final pId = p.id;
        final pPublicKey = p.data['public_key'] as String?;
        if (pPublicKey != null && pPublicKey.isNotEmpty) {
          final sharedSecret = await encryptionService.deriveSharedSecret(
            myKeyPair,
            pPublicKey,
          );
          final encryptedMsgKey = await encryptionService.encryptSymmetricKey(
            messageKey,
            sharedSecret,
          );
          keysMap[pId] = encryptedMsgKey;
        }
      }

      // Encrypt text
      String encryptedText = '';
      if (text != null && text.isNotEmpty) {
        encryptedText = await encryptionService.encryptText(text, messageKey);
      }
      
      bool isMediaUnencrypted = false;
      File? uploadFile = attachment;
      
      if (attachment != null) {
        isMediaUnencrypted = _isMedia(attachment.path);
        if (!isMediaUnencrypted) {
           // Encrypt file
           final fileBytes = await attachment.readAsBytes();
           final encryptedBytes = await encryptionService.encryptBytes(
             fileBytes.toList(),
             messageKey,
           );

           // Write to temp file
           final tempDir = await getTemporaryDirectory();
           final encryptedFile = File(
             '${tempDir.path}/enc_${DateTime.now().millisecondsSinceEpoch}',
           );
           await encryptedFile.writeAsBytes(encryptedBytes);
           uploadFile = encryptedFile;
        }
      }

      // Encode as JSON for the 'text' field
      final payloadData = <String, dynamic>{'e': encryptedText, 'k': keysMap};
      if (isMediaUnencrypted) {
        payloadData['u'] = true;
      }
      final payload = jsonEncode(payloadData);

      final formDataMap = <String, dynamic>{
        "chat_id": chatId,
        "sender_id": myUserId,
        "text": payload,
      };

      if (replyId != null) formDataMap["reply_to"] = replyId;

      if (uploadFile != null) {
        final ext = attachment!.path.contains('.')
            ? attachment.path.split('.').last
            : 'bin';
        final safeName = 'file_${DateTime.now().millisecondsSinceEpoch}.$ext';
        formDataMap["file"] = await dio.MultipartFile.fromFile(
          uploadFile.path,
          filename: safeName,
        );
        formDataMap["attachment"] = await dio.MultipartFile.fromFile(
          uploadFile.path,
          filename: safeName,
        );
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
