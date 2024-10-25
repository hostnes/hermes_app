import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class GetMyChatsEvent extends ChatEvent {
  final String ownerChatId;

  GetMyChatsEvent({
    required this.ownerChatId,
  });
}

class GetChatMessagesEvent extends ChatEvent {
  final String chatId;

  GetChatMessagesEvent({
    required this.chatId,
  });
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String message;
  final String senderId;

  SendMessageEvent({
    required this.chatId,
    required this.message,
    required this.senderId,
  });
}
