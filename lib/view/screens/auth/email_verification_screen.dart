import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/localization_extension.dart';
import '../../widgets/auth/app_button.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerifying = false;
  bool _canResend = true;
  int _timeLeft = 60;
  Timer? _timer;
  Timer? _verificationTimer;
  late UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _userRepository = Provider.of<UserRepository>(context, listen: false);
    _startTimer();
    _checkEmailVerification();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _timeLeft = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isVerifying = true;
    });

    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final isVerified = await _userRepository.reloadUser();
      if (isVerified) {
        timer.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n('email_verified_successfully')), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
          );
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            }
          });
        }
      }
    });

    Future.delayed(const Duration(minutes: 5), () {
      _verificationTimer?.cancel();
      if (mounted) setState(() => _isVerifying = false);
    });
  }

  Future<void> _manuallyCheckVerification() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n('checking_verification_status')), duration: const Duration(seconds: 1)),
    );
    final isVerified = await _userRepository.reloadUser();
    if (isVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('email_verified_successfully')), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          }
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n('email_not_verified')), backgroundColor: Colors.orange),
        );
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend) return;
    await _userRepository.sendEmailVerification();
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n('verification_email_sent_success')), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n('email_verification'), style: const TextStyle(color: AppColors.brown)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brown),
          onPressed: () async {
            await _userRepository.signOut();
            if (mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 100, color: AppColors.orange),
              const SizedBox(height: 24),
              Text(
                context.l10n('verify_your_email'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brown),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n('verification_email_sent'),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_isVerifying)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(context.l10n('checking_verification'), style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _manuallyCheckVerification,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(context.l10n('ive_verified_email')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brown,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              const SizedBox(height: 24),
              BasicAppButton(
                onPressed: _canResend ? _resendVerificationEmail : null,
                title: _canResend ? context.l10n('resend_verification_email') : context.l10n('resend_in_seconds').replaceAll('{seconds}', _timeLeft.toString()),
                backgroundColor: _canResend ? null : Colors.grey,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await _userRepository.signOut();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
                child: Text(context.l10n('back_to_login'), style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}