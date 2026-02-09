import 'package:flutter/widgets.dart' as w;
import 'package:sp_kit/sp_kit.dart';

/// Global feature flag
/// It hold all values that registered from the [SpKit] widget.
final w.ValueNotifier<Map<String, SpFlag>> featureFlagGlobally =
    w.ValueNotifier({});

/// Use this class to register feature flags.
/// It hold the flags value and you can get it back by
/// [SpFeatureFlag.getFeature] method.
abstract class SpFeatureFlag {
  abstract final Map<String, SpFlag> featureFlags;

  SpFeatureFlag() {
    updateFeatureFlags(featureFlags);
  }

  /// Clear existing feature flags and add new flags that provided.
  /// You can call this method to update the feature flags any time.
  /// But the widget tree must be rebuilt by yourself.
  void updateFeatureFlags(Map<String, SpFlag> featureFlags) {
    log("Updating feature flags");
    featureFlagGlobally.value = Map.from(featureFlags);
    log("Feature flags updated");
    for (var f in featureFlags.entries) {
      log("Flag registered: ${f.key}, enabled: ${f.value.enabled}");
    }
    log(featureFlagGlobally.value.values.toSet().toString());
  }

  /// Get flag by name
  static SpFlag getFeature(String featureKey) {
    try {
      final flag = featureFlagGlobally.value.entries
          .firstWhere((f) => f.key == featureKey)
          .value;
      log("Flag found: $featureKey, enabled: ${flag.toString()}");
      return flag;
    } catch (e) {
      throw Exception("Flag not found: $featureKey");
    }
  }

  /// Get flag by type
  static T getFeatureByType<T extends SpFlag>() {
    try {
      final flag = featureFlagGlobally.value.entries
          .firstWhere((f) => f.value is T)
          .value;
      log("Flag found: ${flag.runtimeType}, enabled: ${flag.toString()}");
      return flag as T;
    } catch (e) {
      throw Exception("Flag not found: ${T.toString()}");
    }
  }

  /// Get all flags
  void logFlags() {
    log(
      "Feature flags: $runtimeType, count: ${featureFlagGlobally.value.length}",
    );
    featureFlagGlobally.value.forEach((key, value) {
      log("Flag: $key, enabled: ${value.enabled}");
    });
    log("End of feature flags.");
  }
}
