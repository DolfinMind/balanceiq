# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Gson classes
-keep class com.google.gson.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }

# Keep model classes
-keep class com.dolfinmind.dolfinai.** { *; }

# Prevent stripping of native libraries
-keep class * extends androidx.** { *; }

# Ignore missing Play Core classes (deferred components not used)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# SQLCipher
-keep class net.zetetic.database.sqlcipher.** { *; }
-keep class org.sqlite.database.sqlite.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# R8/ProGuard rules for Coroutines (if used by libraries)
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.CoroutineExceptionHandler {
    <init>(...);
}
