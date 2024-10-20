import 'package:flutter/material.dart';

class Data {
  late String title;
}

class HomeTitleBar extends StatelessWidget {
  const HomeTitleBar({super.key, required this.data});
  final Data data;

  @override
  Widget build(BuildContext context) {
    final title = data.title;
    return Container(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }
}
