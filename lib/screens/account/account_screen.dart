import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/account_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';

class AccountScreen extends StatefulWidget {
  final bool startOnRegister;

  const AccountScreen({super.key, this.startOnRegister = false});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late bool _registerMode;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _registerMode = widget.startOnRegister;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return AppStrings.t(context, 'authEmailRequired');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return AppStrings.t(context, 'authEmailInvalid');
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if ((value ?? '').length < 6) {
      return AppStrings.t(context, 'authPasswordShort');
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final account = context.read<AccountProvider>();
    final email = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text;
    final nickname = _nicknameCtrl.text.trim().isEmpty
        ? email.split('@').first
        : _nicknameCtrl.text.trim();

    final error = _registerMode
        ? await account.register(email, password, nickname)
        : await account.login(email, password);

    if (!mounted) return;
    if (error != null) {
      AppToast.show(
        context,
        title: AppStrings.t(context, error),
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      );
      return;
    }

    AppToast.show(
      context,
      title: AppStrings.t(context, _registerMode ? 'authRegisterSuccess' : 'authLoginSuccess'),
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    final shop = context.watch<ShopProvider>();
    final useShopBg = shop.activeBackgroundId != 'bg_default';

    return Scaffold(
      body: AppDecorations.meshBackground(
        context: context,
        backgroundGradient: useShopBg ? shop.activeBackground.gradient : null,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: account.isBusy ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(
                      child: Text(
                        AppStrings.t(context, _registerMode ? 'authRegisterTitle' : 'authLoginTitle'),
                        style: AppTypography.titleLarge(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: shop.activeTheme.headerGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _registerMode ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppStrings.t(
                              context,
                              _registerMode ? 'authRegisterHeadline' : 'authLoginHeadline',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.t(context, 'authOptionalHint'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppGlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (_registerMode) ...[
                              TextFormField(
                                controller: _nicknameCtrl,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: AppStrings.t(context, 'authNickname'),
                                  hintText: AppStrings.t(context, 'authNicknameHint'),
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              validator: _emailValidator,
                              decoration: InputDecoration(
                                labelText: AppStrings.t(context, 'authEmail'),
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              autofillHints: _registerMode
                                  ? const [AutofillHints.newPassword]
                                  : const [AutofillHints.password],
                              validator: _passwordValidator,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: AppStrings.t(context, 'authPassword'),
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: account.isBusy ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: account.isBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(
                              AppStrings.t(
                                context,
                                _registerMode ? 'authRegisterAction' : 'authLoginAction',
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: account.isBusy
                          ? null
                          : () => setState(() => _registerMode = !_registerMode),
                      child: Text(
                        AppStrings.t(context, _registerMode ? 'authHaveAccount' : 'authNeedAccount'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
