import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isGuest = auth.isGuest;

    void showMessage(String msg) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return WillPopScope(
      onWillPop: () async {
        // When system back is pressed, navigate to Home (index 0) instead of exiting
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const HomeScreen(initialIndex: 0),
            ),
            (route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Account Section
              const SizedBox(height: 12),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        auth.displayName != null && auth.displayName!.isNotEmpty
                            ? auth.displayName![0].toUpperCase()
                            : 'U',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.displayName ?? 'Not signed in',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      // show Guest label only for explicit guest choice, otherwise default to 'Guest' placeholder
                      auth.isGuest ? 'Guest' : (auth.email ?? 'Guest'),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sync Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cloud Sync',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              auth.isLoggedIn
                                  ? (auth.isCloudSyncEnabled
                                        ? 'Your notes are backed up to the cloud.'
                                        : 'Enable to sync across devices.')
                                  : (isGuest
                                        ? 'Login required to enable cloud sync.'
                                        : 'Login required to enable cloud sync.'),
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Opacity(
                        opacity: auth.isLoggedIn && !isGuest ? 1.0 : 0.6,
                        child: Switch(
                          value: auth.isCloudSyncEnabled,
                          onChanged: (v) async {
                            if (!auth.isLoggedIn) {
                              showMessage('Please login to enable Cloud Sync.');
                              return;
                            }
                            if (isGuest) {
                              showMessage(
                                'Please login with an account to enable Cloud Sync.',
                              );
                              return;
                            }

                            await auth.toggleCloudSync();
                            if (auth.isCloudSyncEnabled) {
                              showMessage('Cloud Sync Enabled (Coming Soon)');
                            } else {
                              showMessage('Cloud Sync Disabled');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Actions
              ElevatedButton(
                onPressed: () async {
                  if (auth.isLoggedIn) {
                    await auth.logout();
                    if (context.mounted) {
                      // After logout, navigate to HomeScreen showing the Profile tab
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(initialIndex: 2),
                        ),
                        (route) => false,
                      );
                    }
                  } else {
                    // Not logged in: navigate to Login screen so user can choose to sign in
                    if (context.mounted) {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  }
                },
                child: Text(auth.isLoggedIn ? 'Logout' : 'Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Navigate back to Home screen (clear stack)
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Back to Home'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
