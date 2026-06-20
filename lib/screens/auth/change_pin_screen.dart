import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/pin_keypad.dart';

enum _ChangePinStep { current, newPin, confirm }

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  _ChangePinStep _step = _ChangePinStep.current;
  String _pin = '';
  String? _error;
  bool _loading = false;
  String? _oldPin;
  String? _newPin;

  void _onDigit(String digit) {
    if (_pin.length >= kPinLength || _loading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == kPinLength) _advance();
  }

  void _onBackspace() {
    if (_pin.isEmpty || _loading) return;
    HapticFeedback.lightImpact();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _advance() async {
    switch (_step) {
      case _ChangePinStep.current:
        setState(() => _loading = true);
        final ok = await context.read<AuthProvider>().unlockWithPin(_pin);
        if (!mounted) return;
        setState(() => _loading = false);
        if (!ok) {
          HapticFeedback.heavyImpact();
          setState(() {
            _error = AppStrings.t(context, 'lockWrongPin');
            _pin = '';
          });
          return;
        }
        _oldPin = _pin;
        _goToStep(_ChangePinStep.newPin);
      case _ChangePinStep.newPin:
        if (_pin == _oldPin) {
          HapticFeedback.heavyImpact();
          setState(() {
            _error = AppStrings.t(context, 'pinSameAsOld');
            _pin = '';
          });
          return;
        }
        _newPin = _pin;
        _goToStep(_ChangePinStep.confirm);
      case _ChangePinStep.confirm:
        if (_pin != _newPin) {
          HapticFeedback.heavyImpact();
          setState(() {
            _error = AppStrings.t(context, 'pinMismatch');
            _pin = '';
          });
          return;
        }
        setState(() => _loading = true);
        final changed = await context.read<AuthProvider>().changePin(_oldPin!, _newPin!, _pin);
        if (!mounted) return;
        setState(() => _loading = false);
        if (changed) {
          HapticFeedback.mediumImpact();
          AppToast.show(context, title: AppStrings.t(context, 'pinChanged'));
          Navigator.pop(context, true);
        } else {
          setState(() {
            _error = AppStrings.t(context, 'pinChangeFailed');
            _pin = '';
          });
        }
    }
  }

  void _goToStep(_ChangePinStep step) {
    setState(() {
      _step = step;
      _pin = '';
      _error = null;
    });
  }

  void _onBack() {
    if (_loading) return;
    switch (_step) {
      case _ChangePinStep.current:
        Navigator.pop(context);
      case _ChangePinStep.newPin:
        _goToStep(_ChangePinStep.current);
      case _ChangePinStep.confirm:
        _goToStep(_ChangePinStep.newPin);
    }
  }

  (String title, String subtitle, IconData icon) _labels() => switch (_step) {
        _ChangePinStep.current => (
            AppStrings.t(context, 'changePin'),
            AppStrings.t(context, 'changePinStepCurrent'),
            Icons.lock_outline_rounded,
          ),
        _ChangePinStep.newPin => (
            AppStrings.t(context, 'newPin'),
            AppStrings.t(context, 'changePinStepNew'),
            Icons.lock_reset_rounded,
          ),
        _ChangePinStep.confirm => (
            AppStrings.t(context, 'confirmNewPin'),
            AppStrings.t(context, 'changePinStepConfirm'),
            Icons.check_circle_outline_rounded,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, icon) = _labels();
    return PinEntryShell(
      title: title,
      subtitle: subtitle,
      error: _error,
      filledDots: _pin.length,
      loading: _loading,
      onBack: _onBack,
      onDigit: _onDigit,
      onBackspace: _onBackspace,
      icon: icon,
      step: _step.index,
      totalSteps: 3,
    );
  }
}
