import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

class SecurityService with ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _lockEnabled = true;
  bool _authenticated = false;
  bool _authInProgress = false; // Guard against concurrent auth calls
  DateTime? _lastBackgrounded;
  Duration _timeout = const Duration(minutes: 2);

  bool get lockEnabled => _lockEnabled;
  bool get isAuthenticated => _authenticated;
  bool get authInProgress => _authInProgress;

  void setLockEnabled(bool value) {
    debugPrint('[SecurityService] setLockEnabled: $value');
    _lockEnabled = value;
    notifyListeners();
  }

  void setTimeout(Duration value) {
    debugPrint('[SecurityService] setTimeout: $value');
    _timeout = value;
    notifyListeners();
  }

  void onAppBackgrounded() {
    debugPrint('[SecurityService] App backgrounded at ${DateTime.now()}');
    _lastBackgrounded = DateTime.now();
    _authenticated = false;
    notifyListeners();
  }

  Future<bool> authenticateIfNeeded() async {
    debugPrint('[SecurityService] authenticateIfNeeded called. lockEnabled=$_lockEnabled, authenticated=$_authenticated, lastBackgrounded=$_lastBackgrounded');
    if (!_lockEnabled) {
      debugPrint('[SecurityService] Lock not enabled, skipping authentication.');
      _authenticated = true;
      notifyListeners();
      return true;
    }
    if (_lastBackgrounded != null) {
      final elapsed = DateTime.now().difference(_lastBackgrounded!);
      debugPrint('[SecurityService] Time since backgrounded: $elapsed, timeout=$_timeout');
      if (elapsed < _timeout && _authenticated) {
        debugPrint('[SecurityService] Within timeout and already authenticated.');
        return true;
      }
    }
    return await authenticate();
  }

  Future<bool> authenticate() async {
    if (_authInProgress) {
      debugPrint('[SecurityService] Authentication already in progress, skipping new request.');
      return false;
    }
    _authInProgress = true;
    debugPrint('[SecurityService] authenticate() called');
    final bool deviceSupported = await _auth.isDeviceSupported();
    final bool canCheckBiometrics = await _auth.canCheckBiometrics;
    final isAvailable = deviceSupported || canCheckBiometrics;
    debugPrint('[SecurityService] deviceSupported=$deviceSupported, canCheckBiometrics=$canCheckBiometrics, isAvailable=$isAvailable');
    if (!isAvailable) {
      debugPrint('[SecurityService] No device auth available, bypassing.');
      _authenticated = true;
      notifyListeners();
      _authInProgress = false;
      return true;
    }
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Please authenticate to access Local Cards',
      );
      debugPrint('[SecurityService] Authentication result: $result');
      _authenticated = result;
      notifyListeners();
      return result;
    } catch (e, st) {
      debugPrint('[SecurityService] Authentication error: $e\n$st');
      _authenticated = false;
      notifyListeners();
      return false;
    } finally {
      _authInProgress = false;
    }
  }
}
