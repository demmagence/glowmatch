import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AuthViewModel>().requestPasswordReset(
        _emailController.text.trim(),
      );
      if (mounted) {
        setState(
          () => _message =
              'If an account exists for that email, a reset link has been sent.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.read<AuthViewModel>().errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: const Key('resetEmailField'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Enter a valid email address'
                      : null,
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(_message!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('sendResetButton'),
                  onPressed: auth.isLoading ? null : _submit,
                  child: const Text('Send reset link'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
