import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/reminder_provider.dart';
import 'screens/onboarding_screen.dart';

class RemindyApp extends StatelessWidget {
  const RemindyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ReminderProvider())],
      child: MaterialApp(
        title: 'Remindy',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
