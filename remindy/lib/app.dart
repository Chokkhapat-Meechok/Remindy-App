import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/reminder_provider.dart';
import 'services/auth_service.dart';
import 'screens/onboarding_screen.dart';

// Global messenger key used by the UndoQueue service to show global toasts
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class RemindyApp extends StatelessWidget {
  const RemindyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Remindy',
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF3B82F6),
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
