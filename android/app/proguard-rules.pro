# Flutter-specific ProGuard rules
# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Dart-related classes
-keep class io.flutter.embedding.** { *; }

# Keep annotations
-keepattributes *Annotation*

# Keep all classes with native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve line number information for debugging
-keepattributes SourceFile,LineNumberTable

# If using Gson or JSON serialization
-keepattributes Signature
-keepattributes *Annotation*

# Keep R8 from stripping out any interfaces
-keepnames interface ** { *; }

# Application-specific rules can be added below
