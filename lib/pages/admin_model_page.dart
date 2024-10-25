import 'package:collector_app/pages/admin_create.dart';
import 'package:collector_app/pages/admin_prew_item.dart';
import 'package:flutter/material.dart';
import 'package:collector_app/services/admin.dart';

class AdminModelPage extends StatefulWidget {
  final String modelName;
  final String prewName;
  final bool adminEdit;
  final bool adminDelete;
  final bool adminAdd;

  const AdminModelPage({
    super.key,
    required this.modelName,
    required this.prewName,
    required this.adminEdit,
    required this.adminDelete,
    required this.adminAdd,
  });

  @override
  State<AdminModelPage> createState() => _AdminModelPageState();
}

class _AdminModelPageState extends State<AdminModelPage> {
  List<dynamic> fetchData = [];

  @override
  void initState() {
    _fetchData();
    super.initState();
  }

  void _fetchData() async {
    List res = [];

    Function func = adminActions('get', widget.modelName);
    res = await func();
    if (widget.adminAdd == true) {
      var resS = (res + ['+']).reversed;
      setState(() {
        fetchData = resS.toList();
      });
    } else {
      setState(() {
        fetchData = res.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: ListView.builder(
        itemCount: fetchData.length,
        itemBuilder: (context, index) {
          if (fetchData[index] == '+') {
            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AdminCreate(
                            itemData: fetchData.last,
                            modelName: widget.modelName),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                if (result != null) {
                  setState(() {
                    fetchData.removeAt(index);
                  });
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+',
                      style: TextStyle(fontSize: 35),
                    ),
                  ],
                ),
              ),
            );
          }
          return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AdminPrewItem(
                      modelName: widget.modelName,
                      itemData: fetchData[index],
                      adminAdd: widget.adminAdd,
                      adminDelete: widget.adminDelete,
                      adminEdit: widget.adminEdit,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                if (result != null) {
                  setState(
                    () {
                      fetchData.removeAt(index);
                    },
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Ограничение пространства для текста
                      child: Text(
                        fetchData[index][widget.prewName],
                        overflow: TextOverflow
                            .ellipsis, // Обрезка текста с многоточием
                        maxLines: 1, // Ограничение на одну строку
                        style: TextStyle(
                          fontSize: 16, // Настройка размера шрифта
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: 3.1,
                      child: Icon(Icons.arrow_back_ios),
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }
}
