import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:flutter_chat_room_app/core/encryption/key_manager.dart';

class AuthDataSourceRemote extends IAuthDataSource {
  final PocketBase pb;
  final KeyManager keyManager;

  AuthDataSourceRemote(this.pb, this.keyManager);

  //login
  @override
  Future<void> login(String userName, String password) async {
    try {
      final authRecord = await pb
          .collection('users')
          .authWithPassword(userName, password);

      final userId = authRecord.record.id;

      // Initialize keys for this user
      await keyManager.initialize(userId);

      // If no keys exist on this device, we must generate new ones and update the server
      if (!keyManager.hasKeys()) {
        final publicKey = await keyManager.generateAndStoreKeys(userId);
        await pb
            .collection('users')
            .update(userId, body: {'public_key': publicKey});
      }
    } catch (e) {
      throw ApiException('نام کاربری یا رمز عبور اشتباه است');
    }
  }

  //logOut
  @override
  Future<void> logOut() async {
    final userId = pb.authStore.record?.id;
    if (userId != null) {
      // Optional: don't clear keys on logout so user can login again on same device without losing keys
      // await keyManager.clearKeys(userId);
    }
    pb.authStore.clear();
  }

  //register
  @override
  Future<void> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    // File? avatarFile,
  ) async {
    try {
      final body = <String, dynamic>{
        'userName': userName,
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'name': name,
        'emailVisibility': true,
      };

      await pb.collection('users').create(body: body);

      await login(email, password);
    } on ClientException catch (e) {
      throw ApiException(e.response['message'] ?? 'خطا در ارتباط با سرور');
    } catch (e) {
      throw ApiException('خطای نامشخص در ثبت نام');
    }
  }
}
