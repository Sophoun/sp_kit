/// Use this class to register feature flags.
/// It hold the flags value and you can get it back by
/// [SpFeatureFlag.getFeature] method.
/// Or you can extend it to create your own feature flags.
class SpFlag<T> {
  String key;
  bool enabled;
  String? description;
  T? value;

  SpFlag({
    required this.key,
    required this.enabled,
    this.description,
    this.value,
  });

  @override
  String toString() {
    return '$runtimeType(key: $key, enabled: $enabled, description: $description, value: $value)';
  }
}
