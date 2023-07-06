class SlidingDrawerSettings {
  const SlidingDrawerSettings({
    this.animationDuration = const Duration(milliseconds: 300),
    this.autocompletePercentLimit = 0.05,
    this.drawerWidth = 300,
  });

  final Duration animationDuration;
  final double autocompletePercentLimit;
  final double drawerWidth;
}
