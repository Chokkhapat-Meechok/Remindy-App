import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/reminder_provider.dart';
import 'services/auth_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

// Global messenger key used by the UndoQueue service to show global toasts
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class RemindyApp extends StatefulWidget {
  final bool showOnboarding;

  const RemindyApp({super.key, this.showOnboarding = true});

  @override
  State<RemindyApp> createState() => _RemindyAppState();
}

class _RemindyAppState extends State<RemindyApp> {
  @override
  void initState() {
    super.initState();
    // Wait until providers are created, then handle any pending web redirect result.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final auth = Provider.of<AuthService>(context, listen: false);
        auth.handleRedirectResult();
      } catch (_) {}
    });
  }

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
        debugShowCheckedModeBanner: false,
        home: widget.showOnboarding
            ? const OnboardingScreen()
            : const HomeScreen(),
      ),
    );
  }
}
