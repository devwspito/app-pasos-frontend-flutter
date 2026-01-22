package com.apppasos

import io.flutter.embedding.android.FlutterActivity

/**
 * MainActivity serves as the entry point for the Flutter application on Android.
 *
 * This activity extends FlutterActivity which provides the necessary integration
 * between Android and the Flutter engine. The Flutter engine handles:
 * - Rendering the Flutter UI
 * - Executing Dart code
 * - Managing platform channels for native communication
 *
 * For step tracking functionality, this app requires:
 * - ACTIVITY_RECOGNITION permission (Android 10+)
 * - Access to device step counter sensor
 *
 * The actual step tracking logic is implemented in Flutter/Dart code
 * using platform channels or Flutter plugins like pedometer.
 */
class MainActivity : FlutterActivity()
