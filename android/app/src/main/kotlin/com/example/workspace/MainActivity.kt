package com.example.workspace

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * MainActivity using FlutterFragmentActivity to support
 * Health Connect permission dialogs and activity results.
 * FlutterFragmentActivity is recommended over FlutterActivity
 * for Health Connect because permission request dialogs work
 * better with FragmentActivity lifecycle.
 */
class MainActivity : FlutterFragmentActivity()
