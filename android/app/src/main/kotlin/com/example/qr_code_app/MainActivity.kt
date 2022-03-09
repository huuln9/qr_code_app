package com.example.qr_code_app

import io.flutter.embedding.android.FlutterActivity
import android.content.*
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val QRCODEWIFI_CHANNEL = "vncitizens/qrcodewifi"
    private lateinit var channel: MethodChannel
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QRCODEWIFI_CHANNEL)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "connectWifiInDevice") {
                result.success("huu dep trai")
            }
        }
    }
}
