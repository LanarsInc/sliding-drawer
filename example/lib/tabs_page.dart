import 'package:example/app_router.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:side_panel_flutter/side_panel_container.dart';

import 'side_menu.dart';

@RoutePage()
class TabsPage extends StatefulWidget {
  const TabsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TabsPageState();
  }
}

const feedScreenIndex = 0;
const libraryScreenIndex = 1;
const searchScreenIndex = 2;
const myProfileScreenIndex = 3;
const notificationScreenIndex = 4;

class TabsPageState extends State<TabsPage> with WidgetsBindingObserver {
  final sidePanelKey = GlobalKey<SidePanelContainerState>();

  TextEditingController searchTextController = TextEditingController();
  TextEditingController librarySearchTextController = TextEditingController();
  TextEditingController myBooksSearchTextController = TextEditingController();
  TextEditingController myClubsSearchTextController = TextEditingController();

  bool isConfettiAlreadyShown = false;

  bool isHomeTab = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SidePanelContainer(
      key: sidePanelKey,
      ignorePointer: !isHomeTab,
      onStatusChanged: (status) {
        if (!isHomeTab) sidePanelKey.currentState!.closeSidePanel();
      },
      sidePanel: SideMenu(
        onAction: () => sidePanelKey.currentState!.closeSidePanel(),
      ),
      mainContent: AutoTabsRouter(
        routes: [
          FirstRoute(
            onMenuPressed: () {
              print('isHomeTab: $isHomeTab, ');
              print('context.router.current.name == ${context.router.currentChild?.name}');
              print('FirstRoute.name == ${FirstRoute.name}');
              sidePanelKey.currentState!.openSidePanel();
            },
          ),
          SecondRoute(),
          ThirdRoute(),
          FourthRoute(),
          FifthRoute(),
        ],
        builder: (context, page) {
          final tabsRouter = AutoTabsRouter.of(context);
          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: tabsRouter.activeIndex,
              backgroundColor: Colors.white,
              onTap: (index) {
                tabsRouter.setActiveIndex(index);
                setState(() {
                  isHomeTab = index == 0;
                });
              },
              items: [
                buildBottomNavigationBarItem(
                  Icons.home,
                  'Home',
                  tabsRouter.current.name == FirstRoute.name,
                ),
                buildBottomNavigationBarItem(
                  Icons.local_library_outlined,
                  'Library',
                  tabsRouter.current.name == SecondRoute.name,
                ),
                buildBottomNavigationBarItem(
                  Icons.search,
                  'Search',
                  tabsRouter.current.name == ThirdRoute.name,
                ),
                buildBottomNavigationBarItem(
                  Icons.person,
                  'My Profile',
                  tabsRouter.current.name == FourthRoute.name,
                ),
              ],
            ),
            body: page,
          );
        },
      ),
    );
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
    IconData iconData,
    String title,
    bool isSelected,
  ) {
    return BottomNavigationBarItem(
      label: title,
      icon: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: buildCenteredIcon(iconData, isSelected),
      ),
    );
  }

  Center buildCenteredIcon(IconData iconData, bool isSelected) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Opacity(
            opacity: isSelected ? 1 : 0,
            child: Icon(
              iconData,
              color: Colors.green,
            ),
          ),
          Opacity(
            opacity: isSelected ? 0 : 1,
            child: Icon(
              iconData,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
