import 'package:collector_app/bloc/chat/chat_bloc.dart';
import 'package:collector_app/bloc/chat/chat_event.dart';
import 'package:collector_app/bloc/chat/chat_state.dart';
import 'package:collector_app/components/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String conversationName;

  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.conversationName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ChatBloc _chatBloc = ChatBloc();
  final box = Hive.box("userInfo");
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _chatBloc.add(GetChatMessagesEvent(chatId: widget.conversationId));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels <
          _scrollController.position.minScrollExtent) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _chatBloc.add(SendMessageEvent(
        chatId: widget.conversationId,
        message: message,
        senderId: box.get('auth')['id'].toString(),
      ));
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Icon(
            Icons.arrow_back,
            color:
                Theme.of(context).colorScheme.inversePrimary.withOpacity(0.9),
          ),
        ),
        title: Text(widget.conversationName),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: BlocListener<ChatBloc, ChatState>(
        bloc: _chatBloc,
        listener: (context, state) {
          {
            if (state is ChatMessagesSuccess) {
              setState(() {
                messages = List.from(state.messages['messages'].reversed);
              });
            }
            if (state is SendedMessageSuccess) {
              _chatBloc
                  .add(GetChatMessagesEvent(chatId: widget.conversationId));
              setState(() {
                messages.insert(
                    0, state.message); // Add the new message at the beginning
              });
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                bloc: _chatBloc,
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is ChatMessagesSuccess) {
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return MessageCard(
                            messageData: msg,
                            ownerId: box.get('auth')['id'].toString(),
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: Theme.of(context).colorScheme.tertiary,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Введите сообщение...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
