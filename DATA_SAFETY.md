Data Safety - Remindy (scan summary)

Detected SDKs / libraries (from pubspec.yaml):
- firebase_core
- firebase_auth
- google_sign_in
- flutter_local_notifications
- shared_preferences
- timezone

Likely data types your app may collect or process:
- Identifiers: device identifiers, instance IDs, advertising ID (if used)
- Contact info: email/profile from Google Sign-In
- Usage data: analytics events (via Firebase Analytics if used)
- Diagnostics: crash reports
- Notifications token: FCM tokens for push notifications
- Local storage: preferences stored locally via SharedPreferences

Recommendations for filling Play Console Data safety form:
- Data collected: check identifiers, contact info, diagnostics, usage data, notification tokens, local storage
- Purpose: list purposes such as app functionality (reminders), authentication, analytics, crash reporting, notifications
- Shared with third parties: Yes — Firebase services (Authentication, Analytics, Messaging) and Google Sign-In
- Data encryption: state that data in transit uses HTTPS/TLS (if applicable) and sensitive tokens are stored securely
- User control: explain how users can request deletion or opt-out (e.g., delete account/unlink Google Sign-In)

Next steps I can do:
- Create a draft Data safety form answers file you can copy into Play Console (English/Thai)
- Scan source code for explicit analytics SDK usage (e.g., firebase_analytics) — none declared in pubspec, but check code imports if you used analytics
- Add a short README with exact answers to paste into Play Console
