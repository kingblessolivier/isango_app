import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.onVerify, this.onResend});

  /// Called with the entered OTP. Throw to surface the error banner.
  final Future<void> Function(String otp)? onVerify;

  /// Called when the user requests a new code.
  final Future<void> Function()? onResend;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  static const _length = 6;
  final _controllers =
      List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isComplete =>
      _controllers.every((c) => c.text.length == 1);
  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isComplete) return;
    setState(() => _errorMessage = null);

    if (widget.onVerify == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onVerify!(_otp);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid code. Please check and try again.';
        });
      }
    }
  }

  Future<void> _resend() async {
    if (widget.onResend != null) await widget.onResend!();
    for (final c in _controllers) { c.clear(); }
    _focusNodes.first.requestFocus();
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text('Verify email'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  const Center(
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 72,
                      color: AppColors.logisticsNavy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Check your email',
                    style: AppTextStyles.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Enter the 6-digit code we sent to your inbox.',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.criticalRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        border: Border.all(color: AppColors.criticalRed),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.criticalRed, size: 18),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodyMuted
                                  .copyWith(color: AppColors.criticalRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _length; i++) ...[
                        _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          enabled: !_isLoading,
                          onFilled: () => i < _length - 1
                              ? _focusNodes[i + 1].requestFocus()
                              : _focusNodes[i].unfocus(),
                          onDeleted: i > 0
                              ? () => _focusNodes[i - 1].requestFocus()
                              : null,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (i < _length - 1)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: (_isLoading || !_isComplete) ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verify'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        "Didn't receive a code?",
                        style: AppTextStyles.bodyMuted,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _resend,
                        child: const Text('Resend'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onFilled,
    required this.onChanged,
    this.onDeleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final VoidCallback onFilled;
  final VoidCallback? onDeleted;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 56,
      child: Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onDeleted?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.title,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(counterText: ''),
          onChanged: (value) {
            if (value.isNotEmpty) onFilled();
            onChanged(value);
          },
        ),
      ),
    );
  }
}
