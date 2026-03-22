import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/user/search_user_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/user/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SearchUserUseCase _searchUserUseCase;

  UserBloc(this._searchUserUseCase) : super(UserInitialState()) {
    on<SearchUserEvent>((event, emit) async {
      emit(UserLoadingState());

      var result = await _searchUserUseCase.call(event.userName);

      emit(UserSearchCompletedsState(result));
    });
  }
}
