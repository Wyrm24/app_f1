import 'package:flutter/material.dart';
import 'package:fantasy_f1_app/data/services/supabase_auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseAuthService.instance.resetPassword(
        _emailController.text.trim(),
      );
      if (mounted) setState(() => _emailSent = true);
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _emailSent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEEEE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Color(0xFFE10600),
            size: 28,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email sent.',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Check your inbox at\n${_emailController.text.trim()}\nand follow the link to reset your password.',
          style: TextStyle(color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to login',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Reset\npassword.',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "Enter your email and we'll send you a link to reset your password.",
            style: TextStyle(color: Colors.grey[500], height: 1.5),
          ),

          const SizedBox(height: 36),

          const Text(
            'Email',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSubmit(),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE10600),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE10600)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE10600)),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFE10600),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE10600),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Send reset link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
