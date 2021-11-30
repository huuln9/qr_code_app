import 'package:flutter/material.dart';

class UtilitiesDetailPage extends StatelessWidget {
  final String id;

  const UtilitiesDetailPage({Key? key, required this.id}) : super(key: key);

  static Route route(String id) {
    return MaterialPageRoute(builder: (_) => UtilitiesDetailPage(id: id));
  }

  @override
  Widget build(BuildContext context) {
    return Text(id);
  }
}
