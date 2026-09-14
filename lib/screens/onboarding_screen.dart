import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/app_ui.dart';
import 'auth/lock_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    (Icons.shield_outlined, 'onboardingTitle1', 'onboardingDesc1', AppColors.primary),
    (Icons.fingerprint_rounded, 'onboardingTitle2', 'onboardingDesc2', AppColors.accent),
    (Icons.stars_rounded, 'onboardingTitle3', 'onboardingDesc3', AppColors.coin),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dv_onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SetupPinScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppDecorations.meshBackground(
        context: context,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(onPressed: _finish, child: Text(AppStrings.t(context, 'skip'))),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final (icon, titleKey, descKey, color) = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.06)],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: color.withValues(alpha: 0.25)),
                            ),
                            child: Icon(icon, size: 58, color: color),
                          ),
                          const SizedBox(height: 44),
                          Text(AppStrings.t(context, titleKey), textAlign: TextAlign.center, style: AppTypography.displayLarge()),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.t(context, descKey),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant, height: 1.55),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? context.brand : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(AppStrings.t(context, _page < _pages.length - 1 ? 'next' : 'getStarted')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
