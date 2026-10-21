import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  static const _codeLength = 4;
  static const _countdownSeconds = 45;

  final _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _countdownSeconds;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  String get _timerLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _isComplete => _controllers.every((c) => c.text.length == 1);

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    setState(() {});
  }

  void _onBackspaceWhenEmpty(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  void _resend() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();
    showAppSnack(context, 'Código reenviado', success: true);
  }

  void _submit() {
    if (!_isComplete) {
      showAppSnack(context, 'Ingresa los 4 dígitos del código');
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.newPassword);
  }

  @override
  Widget build(BuildContext context) {
    final canResend = _secondsLeft <= 0;

    return AuthScaffold(
      style: BackgroundStyle.verify,
      onBack: () => Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword),
      children: [
        const SizedBox(height: 20),
        const Align(
          alignment: Alignment.centerLeft,
          child: GradientIconBadge(
            icon: Icons.shield_outlined,
            gradient: AppColors.orange,
            size: 46,
          ),
        ),
        const SizedBox(height: 18),
        ScreenHeading(
          title: 'Verifica tu correo',
          subtitleWidget: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textMuted,
              ),
              children: [
                const TextSpan(text: 'Escribe el código de 4 dígitos que enviamos a\n'),
                TextSpan(
                  text: AppSession.recoveryEmail,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _codeLength,
            (i) => CodeBox(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              onChanged: (v) => _onDigitChanged(i, v),
              onBackspaceWhenEmpty: () => _onBackspaceWhenEmpty(i),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: canResend
              ? GestureDetector(
                  onTap: _resend,
                  child: const Text(
                    'Reenviar código',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    children: [
                      const TextSpan(text: '¿No te llegó? Reenviar código en '),
                      TextSpan(
                        text: _timerLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: 'Siguiente',
          looksDisabled: !_isComplete,
          onPressed: _submit,
        ),
      ],
    );
  }
}

/// Casilla de un solo dígito numérico para el código de verificación.
class CodeBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  /// Se llama al presionar borrar estando la casilla vacía.
  final VoidCallback onBackspaceWhenEmpty;

  const CodeBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspaceWhenEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focused ? AppColors.primary : AppColors.border,
              width: focused ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace &&
                  controller.text.isEmpty) {
                onBackspaceWhenEmpty();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        );
      },
    );
  }
}