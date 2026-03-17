import 'package:bloc/bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/login_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/authentication/register_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/authentication/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc(this._loginUseCase, this._registerUseCase) : super(AuthInitial()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await _loginUseCase(event.userName, event.password);
      emit(AuthSuccess(result));
    });

    on<AuthRegisterEvent>((event, emit) async {
      emit(AuthLoading());

    var result =  await _registerUseCase(
        event.name,
        event.username,
        event.email,
        event.password,
        event.passwordConfirm,
      );

      emit(AuthSuccess(result));
    });
  }
}
