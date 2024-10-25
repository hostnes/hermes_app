import 'package:collector_app/pages/auth_page.dart';
import 'package:collector_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthGate extends StatefulWidget {
  AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final box = Hive.box('userInfo');

  @override
  Widget build(BuildContext context) {
    var user_id = box.get("auth");

    if (user_id != null) {
      return HomePage();
    } else
      return AuthPage();
  }
}
