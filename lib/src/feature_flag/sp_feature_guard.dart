import 'package:flutter/widgets.dart';
import 'package:sp_kit/src/feature_flag/sp_feature_flag.dart';

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
    final flag = SpFeatureFlag.getFeature(flagKey);
    return flag.enabled ? on : off ?? const SizedBox.shrink();
  }
}
