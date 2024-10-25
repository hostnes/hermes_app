import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final Map<String, dynamic> messageData;
  final String ownerId;

  const MessageCard({
    super.key,
    required this.messageData,
    required this.ownerId,
  });

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd HH:mm')
        .format(dateTime); // Форматирует дату и время
  }

  @override
  Widget build(BuildContext context) {
    // Определяем, кто отправил сообщение
    final bool isOwner =
        ownerId == messageData['sender_detail']['id'].toString();

    return Align(
      alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: isOwner
            ? EdgeInsets.fromLTRB(25, 5, 8, 5)
            : EdgeInsets.fromLTRB(8, 5, 25, 5),
        decoration: BoxDecoration(
          color: isOwner ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              messageData['text'],
              style: TextStyle(
                color: isOwner ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4),
            Text(
              formatDateTime(messageData['sent_at']),
              style: TextStyle(
                fontSize: 10,
                color: isOwner ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
