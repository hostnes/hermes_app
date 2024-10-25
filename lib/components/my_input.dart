import 'package:flutter/material.dart';

class MyInput extends StatelessWidget {
  final String labelText;
  final int maxLines;
  final TextEditingController controller;

  const MyInput({
    Key? key,
    required this.labelText,
    required this.controller,
    this.maxLines = 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      controller: controller,
      maxLines: maxLines,
    );
  }
}
