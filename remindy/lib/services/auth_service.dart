import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _displayName;
  String? _email;
  static const _keyLoggedIn = 'auth_is_logged_in';
  static const _keyDisplayName = 'auth_display_name';
  static const _keyEmail = 'auth_email';
  static const _keyCloudSync = 'auth_cloud_sync_enabled';

  AuthService() {
    _loadFromPrefs();
  }

  bool _isCloudSyncEnabled = false;

  bool get isCloudSyncEnabled => _isCloudSyncEnabled;

  Future<void> toggleCloudSync() async {
    _isCloudSyncEnabled = !_isCloudSyncEnabled;
    await _saveToPrefs();
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get displayName => _displayName;
  String? get email => _email;

  // Mock login with email
  Future<void> loginWithEmail({required String email}) async {
    // simulate delay
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    _email = email;
    _displayName = email.split('@').first;
    await _saveToPrefs();
    notifyListeners();
  }

  // Mock login with Google
  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    _displayName = 'Google User';
    _email = 'user@google.mock';
    await _saveToPrefs();
    notifyListeners();
  }

  // Continue as guest (also sets logged in to true but marks guest)
  Future<void> continueAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _isLoggedIn = true;
    _displayName = 'Guest';
    _email = null;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _isLoggedIn = false;
    _displayName = null;
    _email = null;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, _isLoggedIn);
      await prefs.setBool(_keyCloudSync, _isCloudSyncEnabled);
      if (_displayName != null) {
        await prefs.setString(_keyDisplayName, _displayName!);
      } else {
        await prefs.remove(_keyDisplayName);
      }
      if (_email != null) {
        await prefs.setString(_keyEmail, _email!);
      } else {
        await prefs.remove(_keyEmail);
      }
    } catch (e) {
      if (kDebugMode) print('Auth prefs save error: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logged = prefs.getBool(_keyLoggedIn) ?? false;
      _isLoggedIn = logged;
      _displayName = prefs.getString(_keyDisplayName);
      _email = prefs.getString(_keyEmail);
      _isCloudSyncEnabled = prefs.getBool(_keyCloudSync) ?? false;
      if (kDebugMode) print('Auth loaded: $_isLoggedIn / $_displayName');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Auth prefs load error: $e');
    }
  }
}
