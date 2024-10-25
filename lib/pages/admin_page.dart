import 'package:collector_app/components/admin_model_button.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 70),
          child: Column(
            children: [
              AdminModelButton(
                name: "Products",
                prewName: "title",
                adminAdd: false,
                adminDelete: true,
                adminEdit: true,
              ),
              AdminModelButton(
                name: "Users",
                prewName: "name",
                adminAdd: false,
                adminDelete: true,
                adminEdit: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
