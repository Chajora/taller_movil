import 'package:flutter/material.dart';

import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  PasswordRules _rules = PasswordRules.evaluate('');

  bool get _canSubmit =>
      _rules.allMet &&
      _confirmController.text.isNotEmpty &&
      _confirmController.text == _passwordController.text;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!valid || !_canSubmit) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
      arguments: true, // muestra el mensaje de éxito en Login
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      style: BackgroundStyle.newPassword,
      onBack: () => Navigator.pushReplacementNamed(context, AppRoutes.verifyCode),
      children: [
        const SizedBox(height: 14),
        const Align(alignment: Alignment.centerLeft, child: _VerifiedChip()),
        const SizedBox(height: 14),
        const Align(
          alignment: Alignment.centerLeft,
          child: GradientIconBadge(
            icon: Icons.lock_outline,
            gradient: AppColors.purplePink,
            size: 46,
          ),
        ),
        const SizedBox(height: 16),
        const ScreenHeading(
          title: 'Crea una nueva contraseña',
          subtitle: 'Tu nueva contraseña debe ser diferente a las que usaste antes.',
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Nueva contraseña',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                onChanged: (v) =>
                    setState(() => _rules = PasswordRules.evaluate(v)),
                validator: Validators.password,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirmar contraseña',
                hint: '••••••••',
                controller: _confirmController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                onChanged: (_) => setState(() {}),
                validator: Validators.confirm(() => _passwordController.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _RuleRow(label: 'Mínimo 8 caracteres', met: _rules.hasMinLength),
        _RuleRow(label: 'Al menos una mayúscula', met: _rules.hasUppercase),
        _RuleRow(label: 'Al menos un número', met: _rules.hasNumber),
        const SizedBox(height: 18),
        AppButton(
          label: 'Restablecer contraseña',
          looksDisabled: !_canSubmit,
          onPressed: _submit,
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: Color(0xFF16A34A)),
          SizedBox(width: 4),
          Text(
            'Código verificado',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool met;

  const _RuleRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              met ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(met),
              size: 14,
              color: met ? AppColors.success : const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: met ? AppColors.textDark : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}