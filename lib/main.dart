import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';

// Demo toggle to force onboarding to show when needed for demos.
const bool forceShowOnboardingForDemo =
    false; // true เปิดโหมดเดโม่เพื่อแสดงหน้าOnboarding false โหมดปกติ

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase early so auth and other services can use it.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // If initialization fails, continue — services may fallback to non-Firebase paths.
  }

  // Read persisted onboarding flag early (no UI delay) and allow demo override.
  bool hasSeen = false;
  try {
    hasSeen = await const LocalStorageService().hasSeenOnboarding();
  } catch (_) {
    hasSeen = false;
  }

  // Only initialize notifications on platforms that support the plugins
  final shouldInitNotifications =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  if (shouldInitNotifications) {
    // initialize notifications but do not block onboarding decision
    NotificationService.instance.init().catchError((_) {});
  }

  // Decide whether to show onboarding. Demo flag forces onboarding.
  final showOnboarding = forceShowOnboardingForDemo ? true : !hasSeen;

  runApp(RemindyApp(showOnboarding: showOnboarding));
}
