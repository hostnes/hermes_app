import 'package:collector_app/pages/admin_model_page.dart';
import 'package:flutter/material.dart';

class AdminModelButton extends StatefulWidget {
  final String name;
  final String prewName;
  final bool adminEdit;
  final bool adminDelete;
  final bool adminAdd;
  const AdminModelButton({
    super.key,
    required this.name,
    required this.prewName,
    required this.adminEdit,
    required this.adminDelete,
    required this.adminAdd,
  });

  @override
  State<AdminModelButton> createState() => _AdminModelButtonState();
}

class _AdminModelButtonState extends State<AdminModelButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => AdminModelPage(
              prewName: widget.prewName,
              modelName: widget.name,
              adminAdd: widget.adminAdd,
              adminDelete: widget.adminDelete,
              adminEdit: widget.adminEdit,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        padding: EdgeInsets.all(25),
        margin: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.name),
            Transform.rotate(
              angle: 3.1,
              child: Icon(Icons.arrow_back_ios),
            )
          ],
        ),
      ),
    );
  }
}
