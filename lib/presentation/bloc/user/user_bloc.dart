import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/add_friend_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/friend_list_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/get_profile_info_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/search_user_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/update_profile_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SearchUserUseCase _searchUserUseCase;
  final AddFriendUseCase _addFriendUseCase;
  final FriendListUseCase _friendListUseCase;
  final GetProfileInfoUseCase _getProfileInfoUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  UserBloc(
    this._searchUserUseCase,
    this._addFriendUseCase,
    this._friendListUseCase,
    this._getProfileInfoUseCase, {
    required this.updateProfileUseCase,
  }) : super(UserInitialState()) {
    on<SearchUserEvent>((event, emit) async {
      emit(UserSearchLoadingState());

      var result = await _searchUserUseCase.call(event.userName);

      emit(UserSearchComplatedsState(result));
    });

    on<AddFriendEvent>((event, emit) async {
      emit(AddFriendLoadingState());

      var result = await _addFriendUseCase.call(event.userId);

      emit(AddFriendComplatedState(result));
    });

    on<FriendListEvent>((event, emit) async {
      emit(FriendsListLoadingState());

      var result = await _friendListUseCase.call(event.userId);

      emit(FriendListSuccessState(result));
    });

    on<ProfileInfoEvent>((event, emit) async {
      emit(ProfileInfoLoadingState());

      final result = await _getProfileInfoUseCase.call(event.userId);

      emit(ProfileInfoSuccessState(result));
    });

    on<UpdateProfileInfoEvent>((event, emit) async {
      emit(UpdateProfileInfoLoadingState());

      var result = await updateProfileUseCase.call(
        userId: event.userId,
        name: event.name,
        email: event.email,
        userName: event.userName,
      );

      emit(UpdateProfileInfoSuccessState(result));
    });
  }
}
