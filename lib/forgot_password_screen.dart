import 'package:flutter/material.dart';

import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _goToLogin() => Navigator.pushReplacementNamed(context, AppRoutes.login);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppSession.recoveryEmail = _emailController.text.trim();
    Navigator.pushReplacementNamed(context, AppRoutes.verifyCode);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      style: BackgroundStyle.forgot,
      onBack: _goToLogin,
      footer: AuthFooter(
        text: '¿La recordaste?',
        linkText: 'Inicia sesión',
        onTap: _goToLogin,
      ),
      children: [
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: GradientIconBadge(
            icon: Icons.mail_outline,
            gradient: AppColors.blue,
            size: 46,
          ),
        ),
        const SizedBox(height: 18),
        const ScreenHeading(
          title: '¿Olvidaste tu contraseña?',
          subtitle:
              'Ingresa el correo con el que te registraste y te enviaremos un código de 4 dígitos.',
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: AppTextField(
            label: 'Correo electrónico',
            hint: 'tu@correo.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Enviar código', onPressed: _submit),
      ],
    );
  }
}