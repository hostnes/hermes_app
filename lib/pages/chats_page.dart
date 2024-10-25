import 'package:collector_app/bloc/chat/chat_event.dart';
import 'package:collector_app/bloc/chat/chat_state.dart';
import 'package:collector_app/components/botom_navigation_bar.dart';
import 'package:collector_app/components/chat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../bloc/chat/chat_bloc.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final ChatBloc _chatBloc = ChatBloc();
  final box = Hive.box("userInfo");

  @override
  void initState() {
    _chatBloc.add(
      GetMyChatsEvent(
        ownerChatId: box.get('auth')['id'].toString(),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Чаты'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: BlocBuilder(
        bloc: _chatBloc,
        builder: (context, state) {
          if (state is MyChatsSuccess) {
            return SingleChildScrollView(
              child: Column(
                children: state.chatsList.map((chat) {
                  return ChatCard(chatData: chat);
                }).toList(),
              ),
            );
          }
          return Container();
        },
      ),
      bottomNavigationBar: BotomNavigationBar(
        selectedIndex: 2,
      ),
    );
  }
}
