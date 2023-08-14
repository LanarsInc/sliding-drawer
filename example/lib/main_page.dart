import 'package:flutter/material.dart';
import 'package:flutter_sliding_drawer/flutter_sliding_drawer.dart';
import 'side_menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final slidingDrawerKey = GlobalKey<SlidingDrawerState>();

  @override
  Widget build(BuildContext context) {
    final slidingDrawerWidth = MediaQuery.sizeOf(context).width * 0.76;

    return SlidingDrawer(
      key: slidingDrawerKey,
      settings: SlidingDrawerSettings(
        drawerWidth: slidingDrawerWidth,
      ),
      drawerBuilder: (context) {
        return SideMenu(
          onAction: () => slidingDrawerKey.close(),
        );
      },
      contentBuilder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                slidingDrawerKey.open();
              },
              icon: const Icon(
                Icons.menu_rounded,
              ),
            ),
            title: const Text('Home page'),
          ),
          body: Center(
            child: Image.asset(
              'assets/flutter_dash.png',
            ),
          ),
        );
      },
    );
  }
}
