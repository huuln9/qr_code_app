import 'package:flutter/material.dart';
import 'package:vncitizens/src/views/error_page.dart';
import 'package:vncitizens/src/views/main_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MainPage());
      default:
        return MaterialPageRoute(builder: (_) => const ErrorPage());
    }
  }
}
