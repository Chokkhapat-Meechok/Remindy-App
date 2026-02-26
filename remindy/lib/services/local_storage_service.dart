import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight wrapper around SharedPreferences for onboarding flag.
class LocalStorageService {
  const LocalStorageService();

  static const String _key = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key) ?? false;
  }

  Future<void> setSeenOnboarding() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, true);
  }
}
