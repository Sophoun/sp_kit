import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

class ConnectivityService with WidgetsBindingObserver {
  // Singleton pattern for global access
  static final _instance = ConnectivityService._();
  factory ConnectivityService.instance() => _instance;
  ConnectivityService._();

  final _statusController = StreamController<bool>.broadcast();
  Stream<bool> get statusStream => _statusController.stream;

  Timer? _timer;
  bool _lastStatus = true;

  /// Initialize the service and start polling for connectivity status.
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  /// Dispose the service and stop polling.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _statusController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    state == AppLifecycleState.resumed ? _startPolling() : _stopPolling();
  }

  /// Start polling for connectivity status.
  void _startPolling() {
    _checkNow();

    /// Immediate check on resume
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkNow());
  }

  /// Stop polling for connectivity status.
  void _stopPolling() => _timer?.cancel();

  /// Check the connectivity status and update the stream.
  Future<void> _checkNow() async {
    try {
      // DNS lookup is the most reliable "real-world" test
      final result = await InternetAddress.lookup(
        'sophoun.com',
      ).timeout(const Duration(seconds: 3));
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _updateStatus(isOnline);
    } catch (_) {
      _updateStatus(false);
    }
  }

  /// Update the stream with the new connectivity status.
  void _updateStatus(bool status) {
    if (status != _lastStatus) {
      _lastStatus = status;
      _statusController.add(status);
    }
  }
}
