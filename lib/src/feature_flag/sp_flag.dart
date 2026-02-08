/// Use this class to register feature flags.
/// It hold the flags value and you can get it back by
/// [SpFeatureFlag.getFeature] method.
/// Or you can extend it to create your own feature flags.
class SpFlag {
  bool enabled;
  SpFlag(this.enabled);

  @override
  String toString() {
    return '$runtimeType(enabled: $enabled)';
  }
}
