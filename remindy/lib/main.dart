import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize notifications on platforms that support the plugins
  final shouldInitNotifications =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  if (shouldInitNotifications) {
    NotificationService.instance
        .init()
        .catchError((_) {})
        .whenComplete(() => runApp(const RemindyApp()));
  } else {
    runApp(const RemindyApp());
  }
}
