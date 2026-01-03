import 'package:dolfin_core/services/biometric_auth_service.dart';
import 'package:dolfin_ui_kit/dolfin_ui_kit.dart';
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 100),
                const SizedBox(height: 32),
                Text(
                  'Dolfin AI Locked',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Dolfin AI is locked for your security.\nPlease unlock to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Unlock with Biometrics'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
