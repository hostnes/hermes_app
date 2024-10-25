import 'package:collector_app/components/botom_navigation_bar.dart';
import 'package:collector_app/components/product_card.dart';
import 'package:collector_app/pages/create_product_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';

class MyProducts extends StatefulWidget {
  const MyProducts({super.key});

  @override
  State<MyProducts> createState() => _MyProductsState();
}

class _MyProductsState extends State<MyProducts> {
  final _homeBlock = HomeBloc();
  final box = Hive.box('userInfo');

  @override
  void initState() {
    _homeBlock
        .add(SearchProductsEvent(ownerId: box.get('auth')['id'].toString()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Мои объявления'),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: Stack(
        children: [
          BlocBuilder(
            bloc: _homeBlock,
            builder: (context, state) {
              if (state is HomeSuccess) {
                if (state.productList.isNotEmpty) {
                  return ListView.builder(
                    itemCount: state.productList.length,
                    itemBuilder: (context, index) {
                      return ProductCard(
                        cardData: state.productList[index],
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('Ничего не удалось найти :('),
                  );
                }
              }
              if (state is HomeLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Container();
            },
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: GestureDetector(
              onTap: () async {
                var res = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        CreateProduct(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                if (res == true) {
                  _homeBlock.add(
                    SearchProductsEvent(
                      ownerId: box.get('auth')['id'].toString(),
                    ),
                  );
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Добавить",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BotomNavigationBar(
        selectedIndex: 1,
      ),
    );
  }
}
