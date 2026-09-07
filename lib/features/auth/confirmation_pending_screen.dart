import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/auth_viewmodel.dart';
import 'sign_in_screen.dart';

class ConfirmationPendingScreen extends StatefulWidget {
  final String email;

  const ConfirmationPendingScreen({super.key, required this.email});

  @override
  State<ConfirmationPendingScreen> createState() =>
      _ConfirmationPendingScreenState();
}

class _ConfirmationPendingScreenState extends State<ConfirmationPendingScreen> {
  String? _message;

  Future<void> _resend() async {
    try {
      await context.read<AuthViewModel>().resendConfirmationEmail(widget.email);
      if (mounted) setState(() => _message = 'Confirmation email sent.');
    } catch (_) {
      if (mounted) {
        setState(() {
          _message =
              context.read<AuthViewModel>().errorMessage ??
              'Unable to resend the confirmation email.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your email')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72),
              const SizedBox(height: 24),
              Text(
                'We sent a confirmation link to ${widget.email}. Open it before signing in.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('resendConfirmationButton'),
                onPressed: auth.isLoading ? null : _resend,
                child: const Text('Resend confirmation'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                ),
                child: const Text('Back to sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
