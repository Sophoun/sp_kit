import 'package:flutter/widgets.dart';
import 'package:sp_kit/sp_kit.dart';

/// Use it to wrap the widget that you want to hide and show based on the feature flag.
/// [flagKey] is the key of the feature flag.
/// [on] is the widget that will be shown if the feature flag is enabled.
/// [off] is the widget that will be shown if the feature flag is disabled.
/// If [off] is not provided, the widget will not be shown.
class SpFeatureGuard extends StatelessWidget {
  const SpFeatureGuard({
    super.key,
    required this.flagKey,
    required this.on,
    this.off,
  });

  final String flagKey;
  final Widget on;
  final Widget? off;

  @override
  Widget build(BuildContext context) {
    return featureFlagGlobally.builder(
      build: (_) {
        final flag = SpFeatureFlag.getFeature(flagKey);
        log("Checking feature flag: $flagKey flag: $flag");
        return flag.enabled ? on : off ?? const SizedBox.shrink();
      },
    );
  }
}
