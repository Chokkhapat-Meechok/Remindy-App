import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isGuest = auth.displayName == 'Guest';

    void showMessage(String msg) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    return Scaffold(
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
                    auth.email ?? 'Guest',
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
                await auth.logout();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Logout'),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
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
    );
  }
}
