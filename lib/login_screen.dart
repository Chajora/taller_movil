import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'new_password_screen.dart';
import 'register_screen.dart';
import 'verification_code_screen.dart';

void main() => runApp(const AuthFlowApp());

// ───────────────────────── App y rutas ─────────────────────────

class AppRoutes {
  AppRoutes._();
  static const login = '/';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyCode = '/verify-code';
  static const newPassword = '/new-password';
  static const home = '/home';
}

class AuthFlowApp extends StatelessWidget {
  const AuthFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flujo de autenticación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: AppColors.primary),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: (settings) {
        final Widget page;
        switch (settings.name) {
          case AppRoutes.register:
            page = const RegisterScreen();
            break;
          case AppRoutes.forgotPassword:
            page = const ForgotPasswordScreen();
            break;
          case AppRoutes.verifyCode:
            page = const VerificationCodeScreen();
            break;
          case AppRoutes.newPassword:
            page = const NewPasswordScreen();
            break;
          case AppRoutes.home:
            page = const HomeScreen();
            break;
          default:
            page = LoginScreen(showPasswordResetSuccess: settings.arguments == true);
        }
        return PageRouteBuilder<void>(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        );
      },
    );
  }
}

// ───────────────────────── Tema, sesión, validaciones ─────────────────────────

class AppColors {
  AppColors._();
  static const background = Color(0xFFF8F7FF);
  static const primary = Color(0xFF7C3AED);
  static const pink = Color(0xFFEC4899);
  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE9E7F5);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const yellow = Color(0xFFFACC15);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const purplePink = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const purplePinkOrange = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const blue = LinearGradient(
    colors: [Color(0xFF22B8F0), Color(0xFF6D7BF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const orange = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEC4899)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
  static const yellowOrange = LinearGradient(
    colors: [Color(0xFFFACC15), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Datos compartidos entre pantallas (en memoria, sin backend).
class AppSession {
  AppSession._();
  static String email = '';
  static String fullName = '';
  static String recoveryEmail = '';

  static void signOut() {
    email = '';
    fullName = '';
  }
}

class Validators {
  Validators._();

  static final _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');

  static String? required(String? v, [String msg = 'Campo obligatorio']) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegex.hasMatch(v.trim())) {
      return 'Ingresa un correo válido (usuario@dominio.com)';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? Function(String?) confirm(String Function() original) =>
      (v) {
        if (v == null || v.isEmpty) return 'Confirma tu contraseña';
        if (v != original()) return 'Las contraseñas no coinciden';
        return null;
      };
}

class PasswordRules {
  final bool hasMinLength, hasUppercase, hasNumber;

  const PasswordRules(this.hasMinLength, this.hasUppercase, this.hasNumber);

  factory PasswordRules.evaluate(String v) => PasswordRules(
        v.length >= 8,
        v.contains(RegExp(r'[A-Z]')),
        v.contains(RegExp(r'[0-9]')),
      );

  bool get allMet => hasMinLength && hasUppercase && hasNumber;
}

void showAppSnack(BuildContext context, String message, {bool success = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        backgroundColor: success ? AppColors.success : AppColors.textDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
}

void showUnavailableFeature(BuildContext context) =>
    showAppSnack(context, 'Funcionalidad no disponible');

// ───────────────────────── Fondo decorativo ─────────────────────────

enum BackgroundStyle { login, register, forgot, verify, newPassword, home }

enum _Kind { circle, ring, square }

/// Burbujas, aros y cuadros posicionados según el diseño de 390 px de ancho.
class DecorativeBackground extends StatelessWidget {
  final BackgroundStyle style;

  const DecorativeBackground({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = c.maxWidth / 390;
      return Stack(clipBehavior: Clip.hardEdge, children: _shapes(s));
    });
  }

  Widget _shape(
    double s,
    _Kind kind, {
    double? l,
    double? r,
    double? t,
    double? b,
    required double size,
    Color? color,
    Gradient? gradient,
    double angle = 0,
  }) {
    final dim = size * s;
    final BoxDecoration deco;
    switch (kind) {
      case _Kind.circle:
        deco = BoxDecoration(shape: BoxShape.circle, color: color, gradient: gradient);
        break;
      case _Kind.ring:
        deco = BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color!, width: 5 * s),
        );
        break;
      case _Kind.square:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(16 * s),
          gradient: gradient,
        );
        break;
    }
    Widget child = Container(width: dim, height: dim, decoration: deco);
    if (angle != 0) child = Transform.rotate(angle: angle * math.pi / 180, child: child);
    return Positioned(
      left: l == null ? null : l * s,
      right: r == null ? null : r * s,
      top: t == null ? null : t * s,
      bottom: b == null ? null : b * s,
      child: child,
    );
  }

  List<Widget> _shapes(double s) {
    switch (style) {
      case BackgroundStyle.login:
        return [
          _shape(s, _Kind.circle, r: -70, t: -120, size: 290, gradient: AppColors.purplePink),
          _shape(s, _Kind.circle, l: -50, t: 170, size: 110, color: const Color(0xFFD6E4FF)),
          _shape(s, _Kind.circle, l: 48, t: 82, size: 22, color: AppColors.yellow),
          _shape(s, _Kind.ring, l: -22, b: 190, size: 40, color: const Color(0xFF06B6D4)),
          _shape(s, _Kind.circle, l: -60, b: -40, size: 130, color: const Color(0xFFFFD9EC)),
          _shape(s, _Kind.square, r: 20, b: 40, size: 56, gradient: AppColors.yellowOrange, angle: 18),
        ];
      case BackgroundStyle.register:
        return [
          _shape(s, _Kind.circle, r: -90, t: -130, size: 280, gradient: AppColors.purplePinkOrange),
          _shape(s, _Kind.ring, r: 38, t: 170, size: 48, color: const Color(0xFF8B5CF6)),
          _shape(s, _Kind.circle, r: 24, t: 232, size: 20, color: AppColors.yellow),
          _shape(s, _Kind.square, l: -18, b: 6, size: 44, gradient: AppColors.purplePink, angle: 20),
          _shape(s, _Kind.circle, r: -30, b: -20, size: 130, color: const Color(0xFFBFE3F7)),
        ];
      case BackgroundStyle.forgot:
        return [
          _shape(s, _Kind.circle, r: -80, t: -120, size: 280, gradient: AppColors.blue),
          _shape(s, _Kind.ring, r: 34, t: 190, size: 46, color: const Color(0xFF8B5CF6)),
          _shape(s, _Kind.circle, r: 28, t: 240, size: 22, color: AppColors.yellow),
          _shape(s, _Kind.square, l: -18, b: 6, size: 44, gradient: AppColors.purplePink, angle: 20),
          _shape(s, _Kind.circle, r: -30, b: -20, size: 130, color: const Color(0xFFFFE6C2)),
        ];
      case BackgroundStyle.verify:
        return [
          _shape(s, _Kind.circle, r: -90, t: -130, size: 280, gradient: AppColors.purplePinkOrange),
          _shape(s, _Kind.ring, r: 34, t: 200, size: 46, color: const Color(0xFF8B5CF6)),
          _shape(s, _Kind.circle, r: 24, t: 250, size: 20, color: AppColors.yellow),
          _shape(s, _Kind.square, l: -18, b: 6, size: 44, gradient: AppColors.purplePink, angle: 20),
          _shape(s, _Kind.circle, r: -30, b: -20, size: 130, color: const Color(0xFFBFE3F7)),
        ];
      case BackgroundStyle.newPassword:
        return [
          _shape(s, _Kind.circle, r: -80, t: -120, size: 280, gradient: AppColors.purplePink),
          _shape(s, _Kind.circle, r: 20, t: 255, size: 20, color: AppColors.yellow),
          _shape(s, _Kind.circle, l: -50, b: -30, size: 150, color: const Color(0xFFC7DCFF)),
          _shape(s, _Kind.square, r: 12, b: 12, size: 50, gradient: AppColors.orange, angle: 18),
        ];
      case BackgroundStyle.home:
        return [
          _shape(s, _Kind.circle, l: 70, t: 120, size: 26, color: AppColors.yellow),
          _shape(s, _Kind.ring, l: -22, t: 370, size: 40, color: AppColors.pink),
          _shape(s, _Kind.circle, l: -60, b: 20, size: 200, color: const Color(0xFFC7DCFF)),
          _shape(s, _Kind.square, r: 20, b: 150, size: 56, gradient: AppColors.yellowOrange, angle: 18),
        ];
    }
  }
}

// ───────────────────────── Componentes reutilizables ─────────────────────────

/// Estructura común: fondo, barra de estado (9:41), botón atrás, scroll y pie.
class AuthScaffold extends StatelessWidget {
  final BackgroundStyle style;
  final List<Widget> children;
  final Widget? footer;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    required this.style,
    required this.children,
    this.footer,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: DecorativeBackground(style: style)),
          SafeArea(
            child: Column(
              children: [
                const _StatusBar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (onBack != null) ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: _BackButton(onTap: onBack!),
                                      ),
                                    ],
                                    ...children,
                                    const Spacer(),
                                    if (footer != null) footer!,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            const Text(
              '9:41',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Icon(Icons.signal_cellular_alt, size: 16, color: AppColors.textDark),
            const SizedBox(width: 4),
            const Icon(Icons.wifi, size: 16, color: AppColors.textDark),
            const SizedBox(width: 4),
            Container(
              width: 22,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.textDark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.chevron_left, size: 22, color: AppColors.textDark),
        ),
      ),
    );
  }
}

/// Input con etiqueta, validación y ojo para mostrar/ocultar contraseña.
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: 1),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
            errorStyle: const TextStyle(fontSize: 11.5, color: AppColors.error),
            suffixIcon: widget.isPassword
                ? IconButton(
                    splashRadius: 18,
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

enum AppButtonStyle { primary, secondary }

/// Botón primario (degradado) o secundario (blanco con borde).
/// [looksDisabled] lo atenúa pero permite el toque para mostrar errores.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool looksDisabled;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.looksDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = style == AppButtonStyle.primary;
    final dimmed = onPressed == null || looksDisabled;

    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: primary ? AppColors.primaryGradient : null,
          color: primary ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: primary ? null : Border.all(color: AppColors.border),
          boxShadow: primary && !dimmed
              ? [
                  BoxShadow(
                    color: AppColors.pink.withOpacity(0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: primary ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícono cuadrado con degradado (encabezado de pantalla).
class GradientIconBadge extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;

  const GradientIconBadge({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.46),
    );
  }
}

/// Título + subtítulo estándar.
class ScreenHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final TextAlign align;

  const ScreenHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: const TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null || subtitleWidget != null) const SizedBox(height: 8),
        if (subtitleWidget != null)
          subtitleWidget!
        else if (subtitle != null)
          Text(
            subtitle!,
            textAlign: align,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }
}

/// Pie de pantalla: "¿No tienes cuenta? Regístrate".
class AuthFooter extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthFooter({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$text ',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Pantalla: Login ─────────────────────────

class LoginScreen extends StatefulWidget {
  /// Muestra el mensaje de éxito tras restablecer la contraseña.
  final bool showPasswordResetSuccess;

  const LoginScreen({super.key, this.showPasswordResetSuccess = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.showPasswordResetSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showAppSnack(context, 'Contraseña restablecida con éxito', success: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    AppSession.email = _emailController.text.trim();
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      style: BackgroundStyle.login,
      footer: AuthFooter(
        text: '¿No tienes cuenta?',
        linkText: 'Regístrate',
        onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
      ),
      children: [
        const SizedBox(height: 24),
        const Center(
          child: GradientIconBadge(
            icon: Icons.lock_outline,
            gradient: AppColors.purplePink,
          ),
        ),
        const SizedBox(height: 18),
        const ScreenHeading(
          title: 'Bienvenido de nuevo',
          subtitle: 'Inicia sesión para continuar',
          align: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                label: 'Correo electrónico',
                hint: 'tu@correo.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Contraseña',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) => Validators.required(v, 'Ingresa tu contraseña'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        AppButton(label: 'Iniciar sesión', onPressed: _submit),
        const SizedBox(height: 22),
        Row(
          children: const [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'o continúa con',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Google',
                style: AppButtonStyle.secondary,
                onPressed: () => showUnavailableFeature(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Apple',
                style: AppButtonStyle.secondary,
                onPressed: () => showUnavailableFeature(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}