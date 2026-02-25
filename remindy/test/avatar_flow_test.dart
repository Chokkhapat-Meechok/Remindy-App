import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:remindy/app.dart';
import 'package:remindy/screens/home_screen.dart';
import 'package:remindy/screens/login_screen.dart';
import 'package:remindy/screens/profile_screen.dart';
import 'package:remindy/services/auth_service.dart';
import 'package:remindy/providers/reminder_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Ensure SharedPreferences uses an in-memory mock for tests
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Avatar -> Login -> Profile -> Logout flow', (tester) async {
    final auth = AuthService();
    final reminderProvider = ReminderProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<ReminderProvider>.value(
            value: reminderProvider,
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // 1) Fresh launch (not logged in): tap avatar -> LoginScreen
    expect(auth.isLoggedIn, isFalse);
    final loginIconFinder = find.byIcon(Icons.account_circle_outlined);
    expect(loginIconFinder, findsOneWidget);
    await tester.tap(loginIconFinder);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // 2) Complete mock login (Continue with Email) -> return Home
    final emailButton = find.byIcon(Icons.mail_outline);
    expect(emailButton, findsOneWidget);
    await tester.tap(emailButton);
    await tester.pumpAndSettle();

    // Auth should be logged in now
    expect(auth.isLoggedIn, isTrue);

    // Avatar should now be a CircleAvatar with initial 'U'
    final circleAvatarWithInitial = find.byWidgetPredicate((w) {
      if (w is CircleAvatar && w.child is Text) {
        final t = w.child as Text;
        return t.data == 'U' || t.data == 'u';
      }
      return false;
    });
    expect(circleAvatarWithInitial, findsWidgets);

    await tester.tap(circleAvatarWithInitial.first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    // 3) Logout from Profile -> back to Home, tapping avatar goes to LoginScreen
    final logoutButton = find.widgetWithText(ElevatedButton, 'Logout');
    expect(logoutButton, findsOneWidget);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(auth.isLoggedIn, isFalse);

    // Avatar should be icon again
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
