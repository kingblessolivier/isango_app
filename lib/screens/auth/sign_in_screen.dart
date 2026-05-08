import 'package:flutter/material.dart';
import 'package:isango_app/core/constants/app_routes.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onSignIn});

  /// Inject auth implementation. Null = navigate straight to home (UI-only mode).
  /// Throw to surface the error banner; complete normally to proceed.
  final Future<void> Function(String email, String password)? onSignIn;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    if (widget.onSignIn == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.onSignIn!(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sign-in failed. Please check your credentials.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Column(
                      children: [
                        Text(
                          'Isango',
                          style: AppTextStyles.display,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Welcome back!',
                          style: AppTextStyles.title,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Intro
                    Text(
                      'Sign in to access your personalized campus events feed.',
                      style: AppTextStyles.bodyMuted,
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
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          Text(
                            'Email Address',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.nearBlackInk),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              hintText: 'student@ur.ac.rw',
                              prefixIcon: Icon(Icons.mail_outline,
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
                          // Password label row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Password',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.nearBlackInk),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: _isLoading ? null : () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.label.copyWith(
                                      color: AppColors.logisticsNavy),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            enabled: !_isLoading,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              hintText: '••••••••',
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
                                return 'Please enter your password';
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
                                : Text('Sign In', style: AppTextStyles.title.copyWith(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Footer
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyMuted,
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.pushNamed(
                                  context, AppRoutes.signUp),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.logisticsNavy),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Trust badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 12,
                            color: AppColors.mutedOperationalInk),
                        const SizedBox(width: AppSpacing.xxs),
                        Text('Secure University Login',
                            style: AppTextStyles.label),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
