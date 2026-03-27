import 'package:dartz/dartz.dart';
import 'package:flutter_chat_room_app/core/exception/api_exeption.dart';
import 'package:flutter_chat_room_app/domain/entity/user_entity.dart';

abstract class UserState {}

class UserInitialState extends UserState {}

// ---------------- search user ----------------

class UserSearchLoadingState extends UserState {}

class UserSearchComplatedsState extends UserState {
  final Either<ApiException, List<UserEntity>> result;

  UserSearchComplatedsState(this.result);
}

// ---------------- add friend ----------------

class AddFriendLoadingState extends UserState {}

class AddFriendComplatedState extends UserState {
  final Either<ApiException, void> result;

  AddFriendComplatedState(this.result);
}

// ---------------- friend list ----------------

class FriendsListLoadingState extends UserState {}

class FriendListSuccessState extends UserState {
  final Either<ApiException, List<UserEntity>> result;

  FriendListSuccessState(this.result);
}

// ---------------- profile info ----------------

class ProfileInfoLoadingState extends UserState {}

class ProfileInfoSuccessState extends UserState {
  final Either<ApiException, UserEntity> user;
  ProfileInfoSuccessState(this.user);
}
