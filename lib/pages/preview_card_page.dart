import 'package:collector_app/pages/conversation_page.dart';
import 'package:collector_app/pages/my_products.dart';
import 'package:collector_app/pages/profile_page.dart';
import 'package:collector_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class PreviewCardPage extends StatefulWidget {
  final Map<String, dynamic> cardData;

  PreviewCardPage({
    required this.cardData,
    super.key,
  });

  @override
  State<PreviewCardPage> createState() => _PreviewCardPageState();
}

class _PreviewCardPageState extends State<PreviewCardPage> {
  int currentIndex = 0;
  late Map<String, dynamic> productDetails;
  final box = Hive.box('userInfo');

  var likes_box = Hive.box('likes');

  bool get isLiked => likes_box.containsKey(widget.cardData['id'].toString());

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likes_box.delete(widget.cardData['id'].toString());
      } else {
        likes_box.put(widget.cardData['id'].toString(), true);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    productDetails = {
      'Состояние:': widget.cardData['condition'] == "Б" ? "Б/У" : "Новое",
      'Дата:': formatDate(widget.cardData['date']),
      'Место нахождения:':
          "${widget.cardData['owner_details']['district']['title']}, ${widget.cardData['owner_details']['district']['region']}",
      'Категория:':
          "${widget.cardData['sub_category_details']['category']}, ${widget.cardData['sub_category_details']['title']}",
    };
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  void _showDeleteModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение удаления'),
          content: const Text('Вы действительно хотите удалить эту запись?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Да',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              onPressed: () async {
                await ConnectServer.deleteProduct(
                  widget.cardData['id'].toString(),
                );
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        MyProducts(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), //
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    ConnectServer.patchProduct(
                      widget.cardData['id'].toString(),
                      {"is_active": !widget.cardData["is_active"]},
                    );
                    widget.cardData['is_active'] =
                        !widget.cardData["is_active"];
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.cardData['is_active'] == true
                            ? "Деактивировать"
                            : "Активировать",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showDeleteModal();
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Удалить",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Отмена",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
    );
  }

  void _showCallModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16), //
          child: Container(
            width: double
                .infinity, // This ensures the width takes up all available space
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Контакт",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                    height: 10), // Add spacing between the text elements

                const Divider(
                  height: 2,
                ),
                const SizedBox(
                    height: 10), // Add spacing between the text elements

                Text(
                  widget.cardData['owner_details']['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                Text(
                  widget.cardData['owner_details']['phone_number'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                    height: 10), // Add spacing between the text elements

                const Divider(
                  height: 2,
                ),
                const SizedBox(height: 10),
                Text(
                  "Когда будете звонить, скажите что вы по объявлению",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            ProfilePage(
                                userId: widget.cardData['owner_details']['id']
                                    .toString(),
                                isBottomNav: false,
                                isAppArrow: true),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Открыть профиль",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Отмена",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30), // Add spacing between the text elements
              ],
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ), // Optional: Adds rounded corners to the top of the modal
      isScrollControlled:
          true, // Optional: Allows the modal to be full height if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> images = widget.cardData['images'];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index]['image'],
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: GestureDetector(
                              onTap: toggleLike,
                              child: Container(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: isLiked ? Colors.red : Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${currentIndex + 1} / ${images.length}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cardData['title'],
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${widget.cardData['cost']} р",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        formatDate(
                          widget.cardData['date'],
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...productDetails.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                              ),
                              Flexible(
                                child: Text(
                                  entry.value,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 10),
                      Divider(
                        height: 2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${widget.cardData['description']} р",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context)
                      .colorScheme
                      .inversePrimary
                      .withOpacity(0.9),
                ),
              ),
            ),
          ),
          widget.cardData['owner_details']['id'].toString() ==
                  box.get('auth')['id'].toString()
              ? Positioned(
                  top: 20,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _showSettingsModal();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.9),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withOpacity(0.9),
                      ),
                    ),
                  ),
                )
              : Container(),
          Positioned(
            right: 0,
            bottom: 0,
            left: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(1),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showCallModal();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Text('Позвонить'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      var res = await ConnectServer.getConversation(
                        widget.cardData['owner_details']['id'].toString(),
                        box.get("auth")['id'].toString(),
                      );
                      if (res.length != 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationPage(
                              conversationName: widget.cardData['owner_details']
                                  ['name'],
                              conversationId: res[0]['id'].toString(),
                            ),
                          ),
                        );
                      } else {
                        var res = await ConnectServer.postConversation(
                          widget.cardData['owner_details']['id'].toString(),
                          box.get("auth")['id'].toString(),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationPage(
                              conversationName: widget.cardData['owner_details']
                                  ['name'],
                              conversationId: res['id'].toString(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          )),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Text('Написать'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
