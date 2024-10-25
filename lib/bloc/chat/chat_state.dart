import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MyChatsSuccess extends ChatState {
  final List<dynamic> chatsList;

  const MyChatsSuccess({
    required this.chatsList,
  });
}

class ChatMessagesSuccess extends ChatState {
  final Map<String, dynamic> messages;

  const ChatMessagesSuccess({
    required this.messages,
  });
}

class ChatFailure extends ChatState {
  final String error;

  ChatFailure({
    required this.error,
  });
}

class SendedMessageSuccess extends ChatState {
  final Map<String, dynamic> message;

  SendedMessageSuccess({
    required this.message,
  });
}
