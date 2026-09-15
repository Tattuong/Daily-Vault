import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/reviewer_access.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/pin_keypad.dart';
import '../main_shell.dart';
import '../onboarding_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    final auth = context.read<AuthProvider>();
    if (!auth.biometricEnabled || !auth.canUseBiometric) return;
    setState(() => _loading = true);
    final ok = await auth.unlockWithBiometric(AppStrings.t(context, 'biometricReason'));
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) _goToApp();
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _onDigit(String digit) {
    if (_pin.length >= kPinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == kPinLength) _verify();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _verify() async {
    if (_pin.length != kPinLength) return;
    setState(() => _loading = true);
    final ok = await context.read<AuthProvider>().unlockWithPin(_pin);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      _goToApp();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = AppStrings.t(context, 'lockWrongPin');
        _pin = '';
      });
    }
  }

  Future<void> _forgotPin() async {
    final auth = context.read<AuthProvider>();
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2744),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Icon(Icons.warning_amber_rounded, color: AppColors.warning.withValues(alpha: 0.95), size: 44),
              const SizedBox(height: 16),
              Text(
                AppStrings.t(context, 'forgotPinTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.t(context, 'forgotPinDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.72), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              if (auth.biometricEnabled && auth.canUseBiometric) ...[
                _ForgotHintRow(icon: Icons.fingerprint_rounded, text: AppStrings.t(context, 'forgotPinOptionBio')),
                const SizedBox(height: 10),
              ],
              _ForgotHintRow(icon: Icons.delete_forever_outlined, text: AppStrings.t(context, 'forgotPinOptionReset')),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(AppStrings.t(context, 'forgotPinConfirm')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.t(context, 'forgotPinCancel'), style: const TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _loading = true);
    await context.read<VaultProvider>().clearAll();
    await context.read<AuthProvider>().resetAuth();
    if (!mounted) return;

    AppToast.show(context, title: AppStrings.t(context, 'forgotPinDone'));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SetupPinScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: ThemedImmersiveBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Image.asset('assets/logo.png', width: 80, height: 80, fit: BoxFit.cover),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.t(context, 'lockTitle'),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _error ?? AppStrings.t(context, 'lockSubtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _error != null ? AppColors.error : Colors.white.withValues(alpha: 0.75),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        PinDots(filled: _pin.length),
                        if (_loading) ...[
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
                if (auth.biometricEnabled && auth.canUseBiometric) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _loading ? null : _tryBiometric,
                    icon: const Icon(Icons.fingerprint_rounded, color: Colors.white),
                    label: Text(AppStrings.t(context, 'unlockWithBiometric'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
                TextButton(
                  onPressed: _loading ? null : _forgotPin,
                  child: Text(
                    AppStrings.t(context, 'forgotPin'),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotHintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ForgotHintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class SetupPinScreen extends StatefulWidget {
  final bool isConfirm;
  final String? firstPin;

  const SetupPinScreen({super.key, this.isConfirm = false, this.firstPin});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String? _error;
  bool _saving = false;

  void _onDigit(String digit) {
    if (_pin.length >= kPinLength || _saving) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == kPinLength) _submit();
  }

  void _onBackspace() {
    if (_pin.isEmpty || _saving) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _onBack() {
    if (widget.isConfirm) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  Future<void> _submit() async {
    if (_pin.length != kPinLength) {
      setState(() => _error = AppStrings.t(context, 'pinTooShort'));
      return;
    }

    if (!widget.isConfirm) {
      // Play reviewers enter the declared PIN once on Create PIN.
      if (ReviewerAccess.matches(_pin)) {
        await _saveAndEnter(_pin);
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SetupPinScreen(isConfirm: true, firstPin: _pin)),
      );
      if (mounted) setState(() => _pin = '');
      return;
    }

    if (_pin != widget.firstPin) {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = AppStrings.t(context, 'pinMismatch');
        _pin = '';
      });
      return;
    }

    await _saveAndEnter(_pin);
  }

  Future<void> _saveAndEnter(String pin) async {
    setState(() => _saving = true);
    final ok = await context.read<AuthProvider>().setupPin(pin, pin);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } else {
      setState(() {
        _error = AppStrings.t(context, 'pinChangeFailed');
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.isConfirm,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !widget.isConfirm) _onBack();
      },
      child: Scaffold(
        body: ThemedImmersiveBackground(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: _saving ? null : _onBack,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                          ),
                          child: Icon(
                            widget.isConfirm ? Icons.check_circle_outline_rounded : Icons.lock_outline_rounded,
                            size: 36,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            AppStrings.t(context, widget.isConfirm ? 'confirmPinTitle' : 'setupPinTitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _error ?? AppStrings.t(context, widget.isConfirm ? 'confirmPinDesc' : 'setupPinDesc'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _error != null ? AppColors.error : Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        PinDots(filled: _pin.length),
                        if (_saving) ...[
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
