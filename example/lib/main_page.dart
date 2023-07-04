import 'package:flutter/material.dart';
import 'package:side_panel_flutter/side_panel_container.dart';
import 'side_menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final sidePanelKey = GlobalKey<SidePanelContainerState>();

  @override
  Widget build(BuildContext context) {
    return SidePanelContainer(
      key: sidePanelKey,
      sidePanel: SideMenu(
        onAction: () => sidePanelKey.currentState!.closeSidePanel(),
      ),
      mainContent: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              sidePanelKey.currentState!.openSidePanel();
            },
            icon: Icon(
              Icons.menu_rounded,
            ),
          ),
          title: Text('Home page'),
        ),
        body: Center(
          child: Image.asset(
            'assets/flutter_dash.png',
          ),
        ),
      ),
    );
  }
}
