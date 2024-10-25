import 'package:collector_app/pages/conversation_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatelessWidget {
  final Map<String, dynamic> chatData;
  ChatCard({
    super.key,
    required this.chatData,
  });

  final box = Hive.box('userInfo');
  String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat.Hm().format(dateTime); // Форматирует только часы и минуты
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              conversationName: box.get("auth")['id'].toString() ==
                      chatData['participants'][0]['id'].toString()
                  ? chatData['participants'][1]['name']
                  : chatData['participants'][0]['name'],
              conversationId: chatData['id'].toString(),
            ),
          ),
        );
      },
      child: Container(
        child: Column(
          children: [
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            Container(
              height: 100,
              padding: EdgeInsets.all(
                10,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(
                        box.get("auth")['id'].toString() ==
                                chatData['participants'][0]['id'].toString()
                            ? chatData['participants'][1]['photo']
                            : chatData['participants'][0]['photo'],
                      ) as ImageProvider,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              box.get("auth")['di'].toString() ==
                                      chatData['participants'][0]['id']
                                          .toString()
                                  ? chatData['participants'][0]['name']
                                  : chatData['participants'][1]['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            chatData['last_message'] == null
                                ? Text(
                                    "Нету сообщений",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        chatData['last_message']
                                            ['sender_detail']['name'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .inversePrimary),
                                      ),
                                      Text(
                                        chatData['last_message']['text'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        chatData['last_message'] != null
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  formatTime(
                                    chatData['last_message']['sent_at'],
                                  ),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              )
                            : Container()
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
