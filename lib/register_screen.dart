import 'package:flutter/material.dart';

import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToLogin() => Navigator.pushReplacementNamed(context, AppRoutes.login);

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (!_acceptedTerms) {
      showAppSnack(context, 'Debes aceptar los Términos y condiciones');
      return;
    }
    if (!valid) return;
    AppSession.fullName = _nameController.text.trim();
    AppSession.email = _emailController.text.trim();
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      style: BackgroundStyle.register,
      onBack: _goToLogin,
      footer: AuthFooter(
        text: '¿Ya tienes cuenta?',
        linkText: 'Inicia sesión',
        onTap: _goToLogin,
      ),
      children: [
        const SizedBox(height: 20),
        const ScreenHeading(
          title: 'Crea tu cuenta',
          subtitle: 'Completa tus datos para empezar',
        ),
        const SizedBox(height: 22),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Nombre completo',
                hint: 'Juan Pérez',
                controller: _nameController,
                validator: (v) =>
                    Validators.required(v, 'Ingresa tu nombre completo'),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Correo electrónico',
                hint: 'tu@correo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Contraseña',
                hint: 'Mínimo 8 caracteres',
                controller: _passwordController,
                isPassword: true,
                validator: Validators.password,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Confirmar contraseña',
                hint: 'Repite tu contraseña',
                controller: _confirmController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: Validators.confirm(() => _passwordController.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _TermsCheckbox(
          value: _acceptedTerms,
          onChanged: (v) => setState(() => _acceptedTerms = v),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Crear cuenta',
          looksDisabled: !_acceptedTerms,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textMuted);
    const link = TextStyle(
      fontSize: 11.5,
      height: 1.4,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              gradient: value ? AppColors.purplePink : null,
              color: value ? null : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: value ? null : Border.all(color: AppColors.border, width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: 'Acepto los '),
                  TextSpan(text: 'Términos y condiciones', style: link),
                  TextSpan(text: ' y la '),
                  TextSpan(text: 'Política de privacidad', style: link),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}