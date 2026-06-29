import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/security_service.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  const AuthGate({required this.child, super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> with WidgetsBindingObserver {
  bool _authenticating = false;
  bool _showLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      context.read<SecurityService>().onAppBackgrounded();
    }
    if (state == AppLifecycleState.resumed) {
      _checkAuth();
    }
  }

  bool _authRequestInProgress = false; // Prevent overlapping auth calls

  // Updated _checkAuth with guard
  Future<void> _checkAuth() async {
    final security = context.read<SecurityService>();
    if (!security.lockEnabled) {
      setState(() {
        _authenticating = false;
        _showLock = false;
      });
      return;
    }
    // Prevent re-authentication if already authenticated
    if (security.isAuthenticated) {
      setState(() {
        _authenticating = false;
        _showLock = false;
      });
      return;
    }
    if (_authRequestInProgress) {
      debugPrint('[AuthGate] Auth request already in progress, skipping.');
      return;
    }
    _authRequestInProgress = true;
    setState(() {
      _authenticating = true;
    });
    final ok = await security.authenticateIfNeeded();
    setState(() {
      _authenticating = false;
      _showLock = !ok;
    });
    _authRequestInProgress = false;
    if (!ok) {
      _showAuthError();
    }
  }

  void _showAuthError() {
    debugPrint('[AuthGate] Showing authentication error dialog');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Authentication Failed'),
          content: const Text('Could not authenticate. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint(
                    '[AuthGate] Retry pressed, re-attempting authentication');
                Navigator.of(context).pop();
                _checkAuth();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticating) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_showLock) {
      return const Scaffold(
        body: Center(
            child: Text('Authentication required')), // fallback if dialog fails
      );
    }
    return widget.child;
  }
}
