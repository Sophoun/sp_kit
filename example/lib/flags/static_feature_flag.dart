import 'package:sp_kit/sp_kit.dart';

/// Example of feature flag that extends [SpFeatureFlag]
class StaticFeatureFlag extends SpFeatureFlag {
  @override
  Map<String, SpFlag> get featureFlags => {'new_version': NewVersionFlag(true)};
}

/// Example of feature flag that extends [SpFlag]
class NewVersionFlag extends SpFlag {
  NewVersionFlag(super.enabled);
  final String version = "1.0.1-pro";
}
