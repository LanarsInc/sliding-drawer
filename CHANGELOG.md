## 2.0.1 - 27.10.2026
* Fix `setState() called after dispose()` error thrown when `SlidingDrawer` is removed from the tree while its animation is running ([#6](https://github.com/LanarsInc/sliding-drawer/issues/6))
* Fix gestures not being detected on the right side of the screen when `DrawerPosition.right` is used ([#7](https://github.com/LanarsInc/sliding-drawer/issues/7))
* Fix `animationCurve` and `animationReverseCurve` from `SlidingDrawerSettings` being ignored after the widget is updated
* Rebuild drawer animations when `position` changes
* Upgrade Android toolchain in the example app to Gradle 9.3.1, AGP 9.1.0 and Kotlin 2.4.0 (Flutter 3.47)

## 2.0.0 - 14.08.2023
* **Breaking change**. Add `open()`, `close()` and `toggle()` extension methods on `GlobalKey<SlidingDrawerState>`

## 1.0.0+1 - 10.07.2023
* Update README.md

## 1.0.0 - 10.07.2023
* Initial release.
