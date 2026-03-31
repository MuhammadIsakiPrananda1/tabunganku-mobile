# Flutter standard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google ML Kit
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# Shared Preferences
-keep class com.russhwolf.settings.** { *; }

# Flutter Secure Storage
-keep class com.it_workspace.flutter_secure_storage.** { *; }

# Go Router & Riverpod (Prevent obfuscation of state classes)
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep enum com.google.gson.annotations.** { *; }

# Desugaring
-dontwarn j$.**
-keep class j$.** { *; }

# Fix R8 Missing Class Warnings for Play Core (referenced by Flutter)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

