// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:vncitizens/src/views/center_page.dart';
import 'package:vncitizens/src/views/notification_page.dart';
import 'package:vncitizens/src/views/setting_page.dart';
import 'package:home/views/home_page.dart';
import 'package:place/views/place_page.dart';
import 'package:menu/menu_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentPage = 0;
  final List<Screen> _listScreen = [
    Screen(
      body: const HomePage(),
      icon: const Icon(Icons.home),
      label: "Home",
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
    Screen(
      body: const NotificationPage(),
      icon: const Icon(Icons.notifications),
      label: "Notifications",
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
    Screen(
      body: const CenterPage(),
      icon: const Icon(Icons.center_focus_strong),
      label: "Tiền Giang",
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
    Screen(
      body: const SettingPage(),
      icon: const Icon(Icons.settings),
      label: "Setting",
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
    Screen(
      body: const MenuPage(),
      icon: const Icon(Icons.menu_open),
      label: "Menu",
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
  ];

  Widget _navigationTab({GlobalKey<NavigatorState>? naviKey, Widget? widget}) {
    return Navigator(
      key: naviKey,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == "/utilities") {
          final arguments = settings.arguments as List;
          return MaterialPageRoute(
            builder: (_) => PlacePage(
              placeName: arguments[0],
              placeTagId: arguments[1],
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => widget!);
      },
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentPage,
      onTap: (int index) {
        _selectTab(index);
      },
      items: _listScreen
          .map((e) => BottomNavigationBarItem(icon: e.icon, label: e.label))
          .toList(),
    );
  }

  void _selectTab(int index) {
    if (index == _currentPage) {
      _listScreen[index]
          .navigatorKey
          .currentState!
          .popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _listScreen[_currentPage]
            .navigatorKey
            .currentState!
            .maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != 0) {
            _selectTab(1);
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: IndexedStack(
            index: _currentPage,
            children: _listScreen
                .map((e) =>
                    _navigationTab(naviKey: e.navigatorKey, widget: e.body))
                .toList()),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }
}

class Screen {
  final Widget body;
  final Icon icon;
  final String label;
  final GlobalKey<NavigatorState> navigatorKey;

  Screen({
    required this.body,
    required this.icon,
    required this.label,
    required this.navigatorKey,
  });
}
