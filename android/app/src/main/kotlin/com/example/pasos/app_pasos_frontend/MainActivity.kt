package com.example.pasos.app_pasos_frontend

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Health Connect is available on Android 14+ natively
        // For Android 9-13, Health Connect app must be installed from Play Store
        // The health Flutter package handles the permission flow
    }
}
