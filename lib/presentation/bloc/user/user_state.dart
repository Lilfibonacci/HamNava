import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}

class UserSearchCompletedsState extends UserState {
  final Either<ApiException, List<UserEntity>> result;

  UserSearchCompletedsState(this.result);
}
