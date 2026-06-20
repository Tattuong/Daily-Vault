import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;

  bool _isLocked = true;
  bool _pinSetupDone = false;
  bool _biometricEnabled = false;
  bool _canUseBiometric = false;
  bool _initialized = false;

  bool get isLocked => _isLocked;
  bool get pinSetupDone => _pinSetupDone;
  bool get biometricEnabled => _biometricEnabled;
  bool get canUseBiometric => _canUseBiometric;
  bool get initialized => _initialized;

  Future<void> init() async {
    _pinSetupDone = await _auth.isPinSetupDone();
    _biometricEnabled = await _auth.isBiometricEnabled();
    _canUseBiometric = await _auth.canUseBiometric();
    _isLocked = _pinSetupDone;
    _initialized = true;
    notifyListeners();
  }

  Future<bool> setupPin(String pin, String confirmPin) async {
    if (pin.length < 4 || pin != confirmPin) return false;
    await _auth.setupPin(pin);
    _pinSetupDone = true;
    _isLocked = false;
    notifyListeners();
    return true;
  }

  Future<bool> unlockWithPin(String pin) async {
    final ok = await _auth.verifyPin(pin);
    if (ok) {
      _isLocked = false;
      notifyListeners();
    }
    return ok;
  }

  Future<bool> unlockWithBiometric(String reason) async {
    if (!_biometricEnabled || !_canUseBiometric) return false;
    final ok = await _auth.authenticateWithBiometric(reason: reason);
    if (ok) {
      _isLocked = false;
      notifyListeners();
    }
    return ok;
  }

  void lock() {
    if (!_pinSetupDone) return;
    _isLocked = true;
    notifyListeners();
  }

  Future<bool> toggleBiometric(bool enabled, String reason) async {
    if (enabled) {
      if (!_canUseBiometric) return false;
      final ok = await _auth.authenticateWithBiometric(reason: reason);
      if (!ok) return false;
    }
    await _auth.setBiometricEnabled(enabled);
    _biometricEnabled = enabled;
    notifyListeners();
    return true;
  }

  Future<bool> changePin(String oldPin, String newPin, String confirmPin) async {
    if (newPin.length < 4 || newPin != confirmPin) return false;
    try {
      await _auth.changePin(oldPin, newPin);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetAuth() async {
    await _auth.resetVault();
    _pinSetupDone = false;
    _biometricEnabled = false;
    _isLocked = false;
    notifyListeners();
  }
}
