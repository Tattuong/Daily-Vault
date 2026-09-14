import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/vault_provider.dart';
import '../widgets/app_ui.dart';
import 'auth/lock_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final shop = context.read<ShopProvider>();
    await Future.wait([
      shop.init(),
      context.read<AccountProvider>().restore(),
      context.read<VaultProvider>().load(),
    ]);
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('dv_onboarding_seen') ?? false;
    final auth = context.read<AuthProvider>();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Widget next;
    if (!seenOnboarding) {
      next = const OnboardingScreen();
    } else if (!auth.pinSetupDone) {
      next = const SetupPinScreen();
    } else if (auth.isLocked) {
      next = const LockScreen();
    } else {
      next = const MainShell();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedImmersiveBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(top: -80, right: -60, child: _orb(context.brand.withValues(alpha: 0.28), 240)),
            Positioned(bottom: -40, left: -80, child: _orb(Theme.of(context).colorScheme.secondary.withValues(alpha: 0.22), 200)),
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, child) => Transform.scale(scale: 1.0 + _pulse.value * 0.04, child: child),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 32,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/logo.png', width: 128, height: 128, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(AppStrings.t(context, 'appName'), style: AppTypography.displayLarge(color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(
                        AppStrings.t(context, 'appTagline'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(color: Colors.white.withValues(alpha: 0.9), strokeWidth: 2.5),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        AppStrings.t(context, 'splashLoading'),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
