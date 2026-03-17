import 'package:flutter_chat_room_app/core/pocketbase/pocket_base.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/authdatasource/auth_data_source_remote.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_data_source.dart';
import 'package:flutter_chat_room_app/data/dataSource/chatdatasource/chat_remote_data_source.dart';
import 'package:flutter_chat_room_app/data/repository/authrepository/auth_repository.dart';
import 'package:flutter_chat_room_app/data/repository/chatrepository/chat_repository_impl.dart';
import 'package:flutter_chat_room_app/domain/repository/authentication_repository.dart';
import 'package:flutter_chat_room_app/domain/repository/chat_reposiroty.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/is_logedin_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/log_out_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';

var locator = GetIt.instance;

Future<void> getItInit() async {
  locator.registerSingleton<PocketBase>(PocketBaseClient.pb);

  // ۲. دیتاسورس‌ها (DataSources)
  // نکته: اینجا مستقیم کلاس Impl را New می‌کنیم
  locator.registerLazySingleton<IAuthDataSource>(
    () => AuthDataSourceRemote(locator<PocketBase>()),
  );

  locator.registerLazySingleton<IChatDataSource>(
    () => ChatDataSourceImpl(locator<PocketBase>()),
  );

  // ۳. ریپازیتوری‌ها (Repositories)
  // حالا که دیتاسورس‌ها بالا ثبت شده‌اند، می‌توانیم از locator استفاده کنیم
  locator.registerLazySingleton<IAuthenticationRepository>(
    () => AuthRepositoryImpl(locator<IAuthDataSource>()),
  );

  locator.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(locator<IChatDataSource>()),
  );

  // ۴. یوزکیس‌ها (UseCases)
  locator.registerLazySingleton(
    () => LoginUseCase(locator<IAuthenticationRepository>()),
  );
  locator.registerLazySingleton(
    () => RegisterUseCase(locator<IAuthenticationRepository>()),
  );
  locator.registerLazySingleton(
    () => LogOutUseCase(locator<IAuthenticationRepository>()),
  );
  locator.registerLazySingleton(
    () => CheckLoginStatusUseCase(locator<IAuthenticationRepository>()),
  );

  // چت
  locator.registerLazySingleton(
    () => GetAllChatUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => GetMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => ListenToMessageUseCase(locator<IChatRepository>()),
  );
  locator.registerLazySingleton(
    () => SendMessageUseCase(locator<IChatRepository>()),
  );
}
