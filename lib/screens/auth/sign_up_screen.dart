import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onSignUp});

  /// Inject auth implementation. Null = navigate straight to verify-email (UI-only mode).
  /// Throw to surface the error banner; complete normally to proceed.
  final Future<void> Function(String name, String email, String password)?
      onSignUp;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  // White-fill, 12 px-radius decoration used for all sign-up fields.
  static InputDecoration _fieldDecoration({
    required String hint,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hint,
        fillColor: AppColors.cardWhite,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          borderSide:
              const BorderSide(color: AppColors.logisticsNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          borderSide: const BorderSide(color: AppColors.criticalRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          borderSide:
              const BorderSide(color: AppColors.criticalRed, width: 2),
        ),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (widget.onSignUp == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSignUp!(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.verifyEmail);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sign-up failed. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: BackButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text('Create Account', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Join your campus community to never miss an event.',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.mutedOperationalInk),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Submission error banner
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
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Full Name
                        Text(
                          'Full Name',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.nearBlackInk),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          enabled: !_isLoading,
                          decoration: _fieldDecoration(
                            hint: 'John Doe',
                            prefixIcon: const Icon(Icons.person_outline,
                                color: AppColors.mutedOperationalInk),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // University Email
                        Text(
                          'University Email',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.nearBlackInk),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: _fieldDecoration(
                            hint: 'student@ur.ac.rw',
                            prefixIcon: const Icon(Icons.mail_outline,
                                color: AppColors.mutedOperationalInk),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your university email';
                            }
                            if (!value.trim().toLowerCase().endsWith('@ur.ac.rw')) {
                              return 'Please use your university email (e.g. student@ur.ac.rw)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Password
                        Text(
                          'Password',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.nearBlackInk),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                          decoration: _fieldDecoration(
                            hint: '8+ characters',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.mutedOperationalInk),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mutedOperationalInk,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Confirm Password
                        Text(
                          'Confirm Password',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.nearBlackInk),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: _fieldDecoration(
                            hint: '••••••••',
                            prefixIcon: const Icon(Icons.lock_reset,
                                color: AppColors.mutedOperationalInk),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.mutedOperationalInk,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () => setState(
                                      () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton(
                          onPressed: _isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadii.button),
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
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Create Account',
                                      style: AppTextStyles.title
                                          .copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    const Icon(Icons.arrow_forward,
                                        size: 18, color: Colors.white),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'We will send you a verification link to your email after you sign up.',
                    style: AppTextStyles.bodyMuted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTextStyles.bodyMuted,
                      ),
                      TextButton(
                        onPressed:
                            _isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Log in',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.logisticsNavy),
                        ),
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
