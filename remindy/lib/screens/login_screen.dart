import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Sign in to enable Cloud Sync',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await auth.loginWithEmail(email: 'user@example.mock');
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.mail_outline),
              label: const Text('Continue with Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await auth.loginWithGoogle();
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.g_mobiledata),
              label: const Text('Continue with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await auth.continueAsGuest();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Continue as Guest'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe later'),
            ),
          ],
        ),
      ),
    );
  }
}
