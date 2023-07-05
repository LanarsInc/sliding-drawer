class SidePanelContainerSettings {
  const SidePanelContainerSettings({
    this.animationDuration = const Duration(milliseconds: 300),
    this.autocompletePercentLimit = 0.05,
    this.sidePanelWidthToScreenWidthRatio = 0.75,
  });

  final Duration animationDuration;
  final double autocompletePercentLimit;
  final double sidePanelWidthToScreenWidthRatio;
}
