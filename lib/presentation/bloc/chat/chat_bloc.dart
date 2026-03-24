import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/delete_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_all_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/get_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/listen_to_message_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/private_chat_use_case.dart';
import 'package:flutter_chat_room_app/domain/usecase/chat/send_message_use_case.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_event.dart';
import 'package:flutter_chat_room_app/presentation/bloc/chat/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessageUseCase _getMessageUseCase;
  final PrivateChatUseCase _privateChatUseCase;
  final ListenToMessageUseCase _listenMessagesUseCase;
  final DeleteChatUseCase _deleteChatUseCase;
  final GetAllChatUseCase _getAllChatUseCase;

  StreamSubscription? _messageSubscription;

  ChatBloc(
    this._sendMessageUseCase,
    this._getMessageUseCase,
    this._privateChatUseCase,
    this._listenMessagesUseCase,
    this._deleteChatUseCase,
    this._getAllChatUseCase,
  ) : super(ChatInitialState()) {
    on<ChatInitializeEvent>((event, emit) async {
      emit(ChatLoadingState());
      final result = await _privateChatUseCase.call(event.targetUserId);
      emit(ChatInitializedResultState(result));
    });

    on<LoadMessagesEvent>((event, emit) async {
      final result = await _getMessageUseCase.call(event.chatId);
      emit(ChatMessagesResultState(result));

      _messageSubscription?.cancel();
      _messageSubscription = _listenMessagesUseCase.call(event.chatId).listen((
        newMessage,
      ) {
        add(ChatMessageReceivedFromStreamEvent(newMessage));
      });
    });

    on<ChatMessageReceivedFromStreamEvent>((event, emit) {
      emit(ChatNewMessageResultState(event.message));
    });

    on<SendMessageEvent>((event, emit) async {
      final result = await _sendMessageUseCase.call(
        chatId: event.chatId,
        text: event.text,
      );
      emit(ChatMessageSentResultState(result));
    });

    on<DeleteMessageEvent>((event, emit) async {
      var result = await _deleteChatUseCase.call(event.messageId);

      emit(DeleteMessageSuccessState(result));
    });

    on<GetChatListEvent>((event, emit) async {
      emit(ChatLoadingState());

      final result = await _getAllChatUseCase.call();

      emit(ChatListSUccessState(result));
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
