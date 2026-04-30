# Project-specific ProGuard rules for Flutter
# Keep Flutter engine and plugin classes
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Firebase classes (common)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Kotlin metadata
-keepclassmembers class kotlin.Metadata { *; }
