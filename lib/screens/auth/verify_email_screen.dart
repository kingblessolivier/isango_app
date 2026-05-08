import 'package:flutter/material.dart';
import 'package:isango_app/core/theme/app_colors.dart';
import 'package:isango_app/core/theme/app_radii.dart';
import 'package:isango_app/core/theme/app_spacing.dart';
import 'package:isango_app/core/theme/app_text_styles.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.onResend});

  /// Called when the user requests a new verification email.
  /// Throw to surface the error banner; complete normally to show success feedback.
  final Future<void> Function()? onResend;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _resend() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (widget.onResend == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      await widget.onResend!();
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage =
            'Failed to resend. Please try again in a moment.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mistBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.softBorder, height: 1),
        ),
        leading: BackButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: Text('Verify Email', style: AppTextStyles.headline),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Status panel
              Container(
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
                  border: Border.all(color: AppColors.softBorder),
                ),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Icon in circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.paleSignalBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread,
                        size: 32,
                        color: AppColors.logisticsNavy,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Verification Pending',
                      style: AppTextStyles.headline,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "We've sent a verification link to your student email. "
                      'Please check your inbox to activate your account.',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.mutedOperationalInk),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Why verify block
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified,
                      color: AppColors.commandBlue,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Why verify your email?',
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Verified students can RSVP to exclusive campus events, '
                            'create their own event listings, and receive priority notifications.',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Error banner
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
              // Resend button
              FilledButton(
                onPressed: _isLoading ? null : _resend,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  elevation: 3,
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
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.send, size: 18, color: Colors.white),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Resend Verification Email',
                            style: AppTextStyles.title
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Support text
              Text(
                "Can't find the email? Check your spam folder or try resending in 2 minutes.",
                style: AppTextStyles.bodyMuted
                    .copyWith(color: const Color(0xFF757682)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
