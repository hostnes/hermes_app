import 'package:bloc/bloc.dart';
import '../../services/api.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<GetMyChatsEvent>(
      (GetMyChatsEvent event, Emitter<ChatState> emit) async {
        emit(ChatLoading());
        try {
          final res = await ConnectServer.getMyChats(event.ownerChatId);
          emit(MyChatsSuccess(chatsList: res));
        } catch (e) {
          emit(ChatFailure(error: 'Ошибка Загрузки чатов'));
        }
      },
    );
    on<GetChatMessagesEvent>(
      (GetChatMessagesEvent event, Emitter<ChatState> emit) async {
        emit(ChatLoading());
        try {
          final res = await ConnectServer.getChatMessages(event.chatId);
          emit(ChatMessagesSuccess(messages: res));
        } catch (e) {
          emit(ChatFailure(error: "Ошибка получания сообщений"));
        }
      },
    );
    on<SendMessageEvent>(
      (SendMessageEvent event, Emitter<ChatState> emit) async {
        try {
          final res = await ConnectServer.postMessages(
            chatId: event.chatId,
            message: event.message,
            senderId: event.senderId,
          );
          await ConnectServer.patchConversation(
            event.chatId,
          );
          emit(SendedMessageSuccess(message: res));
        } catch (e) {
          emit(ChatFailure(error: "Ошибка отправки сообщений"));
        }
      },
    );
  }
}
