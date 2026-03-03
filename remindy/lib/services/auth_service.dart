import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart' as gsign;

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

  // Tracks whether the user explicitly chose to continue as Guest
  bool _isGuest = false;
  bool get isCloudSyncEnabled => _isCloudSyncEnabled;

  Future<void> toggleCloudSync() async {
    _isCloudSyncEnabled = !_isCloudSyncEnabled;
    await _saveToPrefs();
    notifyListeners();
  }

  bool get isLoggedIn => _isLoggedIn;
  String? get displayName => _displayName;
  String? get email => _email;

  // Login with email/password. This is a local placeholder; replace with
  // Firebase auth integration later. Validates basic email format and non-empty
  // password. Throws `FormatException` on invalid input.
  Future<void> loginWithEmail({required String email, String? password}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Basic validation (placeholder)
    if (email.isEmpty || !email.contains('@')) {
      throw FormatException('Please enter a valid email address.');
    }
    if (password == null || password.isEmpty || password.length < 4) {
      throw FormatException('Please enter a password (min 4 chars).');
    }

    // Simulate successful authentication
    _isLoggedIn = true;
    _isGuest = false;
    _email = email;
    _displayName = email.split('@').first;
    await _saveToPrefs();
    notifyListeners();
  }

  // Mock login with Google
  Future<void> loginWithGoogle() async {
    // Try Firebase + Google Sign-In. Fall back to mock behavior if something fails.
    try {
      if (kIsWeb) {
        // On web, try popup first. If popup is blocked/fails, fall back to redirect.
        final provider = fb_auth.GoogleAuthProvider();
        try {
          final result = await fb_auth.FirebaseAuth.instance.signInWithPopup(
            provider,
          );
          final user = result.user;
          if (user != null) {
            _isLoggedIn = true;
            _isGuest = false;
            _displayName = user.displayName;
            _email = user.email;
            await _saveToPrefs();
            notifyListeners();
            return;
          }
        } catch (e) {
          if (kDebugMode)
            print('Popup sign-in failed, falling back to redirect: $e');
          // Use redirect flow; this will navigate away from the app and
          // the result should be handled after app startup via `getRedirectResult()`.
          await fb_auth.FirebaseAuth.instance.signInWithRedirect(provider);
          return;
        }
      } else {
        // Native platforms: use google_sign_in to get tokens, then sign into Firebase.
        final googleSignIn = gsign.GoogleSignIn.instance;
        // Ensure the plugin is initialized for the app; no-op if already done.
        try {
          await googleSignIn.initialize();
        } catch (_) {}
        final gsign.GoogleSignInAccount account = await googleSignIn
            .authenticate(scopeHint: ['email']);
        // `authentication` is synchronous and currently exposes `idToken`.
        final gsign.GoogleSignInAuthentication auth = account.authentication;
        final credential = fb_auth.GoogleAuthProvider.credential(
          idToken: auth.idToken,
        );
        final userCredential = await fb_auth.FirebaseAuth.instance
            .signInWithCredential(credential);
        final u = userCredential.user;
        if (u != null) {
          _isLoggedIn = true;
          _isGuest = false;
          _displayName = u.displayName;
          _email = u.email;
          await _saveToPrefs();
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('Google sign-in failed: $e');
    }
    // Fallback mock behavior if Firebase sign-in not available or failed
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = true;
    _isGuest = false;
    _displayName = 'Google User';
    _email = 'user@google.mock';
    await _saveToPrefs();
    notifyListeners();
  }

  // Handle a pending web redirect result (called after Firebase initialization
  // when the app starts). This checks whether a redirect-based sign-in just
  // completed and updates local auth state accordingly.
  Future<void> handleRedirectResult() async {
    if (!kIsWeb) return;
    try {
      final result = await fb_auth.FirebaseAuth.instance.getRedirectResult();
      final user = result.user;
      if (user != null) {
        _isLoggedIn = true;
        _isGuest = false;
        _displayName = user.displayName;
        _email = user.email;
        await _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Redirect result handling failed: $e');
    }
  }

  // Continue as guest (also sets logged in to true but marks guest)
  Future<void> continueAsGuest() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Mark as guest mode but do NOT mark as logged in —
    // guest should be an explicit user choice and not treated as an authenticated session.
    _isGuest = true;
    _isLoggedIn = false;
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
    _isGuest = false;
    try {
      // Sign out from Firebase and Google if available
      await fb_auth.FirebaseAuth.instance.signOut();
      await gsign.GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, _isLoggedIn);
      await prefs.setBool('auth_is_guest', _isGuest);
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
      _isGuest = prefs.getBool('auth_is_guest') ?? false;
      // Ensure guest mode does not imply authenticated session
      if (_isGuest) _isLoggedIn = false;
      if (kDebugMode) print('Auth loaded: $_isLoggedIn / $_displayName');
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Auth prefs load error: $e');
    }
  }

  // Public getter for guest flag
  bool get isGuest => _isGuest;
}
