import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

const int kPinLength = 4;

class PinDots extends StatelessWidget {
  final int filled;

  const PinDots({super.key, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(kPinLength, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: isFilled ? 18 : 16,
          height: isFilled ? 18 : 16,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.white : Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: isFilled ? 0 : 1.5),
            boxShadow: isFilled
                ? [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 10)]
                : null,
          ),
        );
      }),
    );
  }
}

class PinKeypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({super.key, required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    final compact = MediaQuery.sizeOf(context).height < 700;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compact ? 280 : 300),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: compact ? 10 : 14,
              crossAxisSpacing: compact ? 10 : 14,
              childAspectRatio: compact ? 1.65 : 1.55,
            ),
            itemCount: keys.length,
            itemBuilder: (_, i) {
              final key = keys[i];
              if (key.isEmpty) return const SizedBox.shrink();
              if (key == '⌫') {
                return _PinKey(isBackspace: true, compact: compact, onTap: onBackspace);
              }
              return _PinKey(label: key, compact: compact, onTap: () => onDigit(key));
            },
          ),
        ),
      ),
    );
  }
}

class _PinKey extends StatelessWidget {
  final String? label;
  final bool isBackspace;
  final bool compact;
  final VoidCallback onTap;

  const _PinKey({this.label, this.isBackspace = false, this.compact = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(compact ? 16 : 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        splashColor: Colors.white.withValues(alpha: 0.08),
        child: Center(
          child: isBackspace
              ? Icon(Icons.backspace_outlined, color: Colors.white, size: compact ? 20 : 22)
              : Text(
                  label!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 22 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Full-screen PIN entry shell matching vault auth screens.
class PinEntryShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? error;
  final int filledDots;
  final bool loading;
  final VoidCallback onBack;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final IconData icon;
  final int step;
  final int totalSteps;

  const PinEntryShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.error,
    required this.filledDots,
    this.loading = false,
    required this.onBack,
    required this.onDigit,
    required this.onBackspace,
    required this.icon,
    required this.step,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 700;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: loading ? null : onBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(totalSteps, (i) {
                        final active = i <= step;
                        final current = i == step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: current ? 28 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: compact ? 8 : 16),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 72 : 80,
                        height: compact ? 72 : 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                        ),
                        child: Icon(icon, size: compact ? 32 : 36, color: Colors.white.withValues(alpha: 0.95)),
                      ),
                      SizedBox(height: compact ? 24 : 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          error ?? subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: error != null ? AppColors.error : Colors.white.withValues(alpha: 0.7),
                            fontSize: compact ? 14 : 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 32 : 48),
                      PinDots(filled: filledDots),
                      if (loading) ...[
                        const SizedBox(height: 24),
                        const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              PinKeypad(onDigit: onDigit, onBackspace: onBackspace),
              SizedBox(height: compact ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }
}
