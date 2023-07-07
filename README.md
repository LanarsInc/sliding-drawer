[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://vshymanskyy.github.io/StandWithUkraine)

[![pub package](https://img.shields.io/pub/v/flutter_sliding_drawer.svg)](https://pub.dev/packages/flutter_sliding_drawer)

If you want to add a beautiful sliding animation menu to your application in an easy way, you can use this package.
All you need is to pass your main content and drawer widgets to the SlidingDrawer.

<img src="https://raw.githubusercontent.com/LanarsInc/sliding-drawer/main/example/assets/sliding_drawer_example.gif" width="300">

# How to use

To use the SlidingDrawer pass build functions `drawerBuilder` and `mainContentBuilder` that return drawer
and main content widgets correspondingly.\
You can set drawer width, animation duration and curve by using `settings` argument.\
Set `ignorePointer` to true if you need to disable opening/closing drawer by dragging.\
To respond to opening/closing drawer, API provide listener `onAnimationStatusChanged`.

# Example

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // Optional. Provide Key<SlidingDrawerState> if you want
  // to open/close the drawer in response to some action
  final slidingDrawerKey = GlobalKey<SlidingDrawerState>();

  @override
  Widget build(BuildContext context) {
    return SlidingDrawer(
      key: slidingDrawerKey,
      // Build main content widget
      mainContentBuilder: (context) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
              ),
              onPressed: () {
                // Open drawer
                slidingDrawerKey.currentState!.openSlidingDrawer();
              },
            ),
            title: const Text('Home page'),
          ),
          body: const MyHomePageBodyWidget(),
        );
      },
      // Build drawer widget
      drawerBuilder: (context) {
        return MyDrawerWidget(
            onItemPress: () {
              // Close drawer
              slidingDrawerKey.currentState!.closeSlidingDrawer();
            }
        );
      },
    );
  }
}
```