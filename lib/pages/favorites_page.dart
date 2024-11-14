import 'package:collector_app/components/botom_navigation_bar.dart';
import 'package:collector_app/components/product_card.dart';
import 'package:collector_app/services/api.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final box = Hive.box('likes');
  List<String> likedProductIds = [];
  List<dynamic> likedProducts = [];

  @override
  void initState() {
    super.initState();
    loadLikedProducts();
  }

  void loadLikedProducts() async {
    // Retrieve all liked product IDs from Hive
    likedProductIds = box.keys.map((key) => key.toString()).toList();
    setState(() {}); // Trigger rebuild to display the loaded IDs
    for (var prodId in likedProductIds) {
      try {
        final productData = await ConnectServer.getProduct(prodId.toString());
        likedProducts.add(productData);
      } catch (e) {}
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Избранное'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: likedProductIds.isEmpty
          ? Center(child: Text('Нет избранных товаров'))
          : ListView.builder(
              itemCount: likedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(cardData: likedProducts[index]);
              },
            ),
      bottomNavigationBar: BotomNavigationBar(
        selectedIndex: 4,
      ),
    );
  }
}
