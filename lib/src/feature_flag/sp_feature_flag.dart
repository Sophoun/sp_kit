import 'package:flutter/widgets.dart' as w;
import 'package:sp_kit/sp_kit.dart';

/// Global feature flag notifier
final w.ValueNotifier<Set<SpFlag>> featureFlagsGlobally = w.ValueNotifier({});

/// A static utility class to manage feature flags.
class SpFeatureFlag {
  // Prevent instantiation
  SpFeatureFlag._();

  /// Register or merge new feature flags into the global state.
  static void registerFlags(Set<SpFlag> flags) {
    log("Updating feature flags");

    // Merge new flags with existing ones instead of completely overwriting
    final updatedMap = Set<SpFlag>.from(flags);

    featureFlagsGlobally.value = updatedMap;

    for (var f in flags) {
      log("Flag registered: ${f.key}, enabled: ${f.enabled}");
    }
  }

  /// Get flag by string key (Optimized for direct Map lookup)
  static SpFlag getFeature(String key) {
    final flag = featureFlagsGlobally.value.firstWhere(
      (e) => e.key == key,
      orElse: () => throw Exception("Feature Flag not found: $key"),
    );

    log("Flag found: $key, enabled: ${flag.enabled}");
    return flag;
  }

  /// Log all currently registered flags
  static void logFlags() {
    final flags = featureFlagsGlobally.value;
    log("Feature flags count: ${flags.length}");
    for (var f in flags) {
      log("Flag: ${f.key}, enabled: ${f.enabled}");
    }
    log("End of feature flags.");
  }
}
