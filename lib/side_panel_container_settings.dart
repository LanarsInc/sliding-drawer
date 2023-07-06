class SidePanelContainerSettings {
  const SidePanelContainerSettings({
    this.animationDuration = const Duration(milliseconds: 300),
    this.autocompletePercentLimit = 0.05,
    this.sidePanelWidth = 300,
  });

  final Duration animationDuration;
  final double autocompletePercentLimit;
  final double sidePanelWidth;
}
