import 'package:dolfin_core/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isLocked = false;
  bool _enabled = false;
  bool _isAuthenticating = false;
  final _biometricService = GetIt.I<BiometricAuthService>();

  @override
  void initState() {
    super.initState();
    _checkAppLockEnabled();
  }

  Future<void> _checkAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('is_app_lock_enabled') ?? false;
    if (_enabled) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    if (mounted) {
      setState(() => _isLocked = true);
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Unlock Dolfin AI',
    );

    _isAuthenticating = false;

    if (authenticated && mounted) {
      setState(() => _isLocked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('App Locked', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      );
    }
    return widget.child;
  }
}
