import 'package:collector_app/pages/chats_page.dart';
import 'package:collector_app/pages/favorites_page.dart';
import 'package:collector_app/pages/home_page.dart';
import 'package:collector_app/pages/my_products.dart';
import 'package:collector_app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BotomNavigationBar extends StatefulWidget {
  final selectedIndex;

  const BotomNavigationBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  State<BotomNavigationBar> createState() => _BotomNavigationBarState();
}

class _BotomNavigationBarState extends State<BotomNavigationBar> {
  final box = Hive.box('userInfo');
  String userId = '0';
  @override
  void initState() {
    _fetchData();
  }

  void _fetchData() async {
    var res = box.get('auth')['id'].toString();
    setState(() {
      userId = res;
    });
    super.initState();
  }

  void changePage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => HomePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      case 1:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MyProducts(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      case 2:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ChatsPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => ProfilePage(
              userId: userId,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      case 4:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => FavoritesPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: widget.selectedIndex,
        onTap: changePage,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        items: const [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.collections,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.format_list_bulleted_sharp,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.chat,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.person,
              size: 40,
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(
              Icons.favorite,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}
