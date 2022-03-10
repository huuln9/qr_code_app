package com.example.qr_code_app

import io.flutter.embedding.android.FlutterActivity
import android.content.*
import android.net.wifi.WifiNetworkSpecifier
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.NetworkRequest
import android.net.NetworkCapabilities
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val QRCODEWIFI_CHANNEL = "vncitizens/connectwifi"
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QRCODEWIFI_CHANNEL)

        channel.setMethodCallHandler { call, result ->
            if (call.method == "connectWifiInDevice") {
                val arguments = call.arguments() as Map<String, String>

                val networkSSID = arguments["ssid"] ?: ""
                val networkPassword = arguments["password"] ?: ""

                val wifiManager = applicationContext.getSystemService(WIFI_SERVICE) as WifiManager?
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    try {
                        val wifiConfig = WifiConfiguration()
                        wifiConfig.SSID = "\"" + networkSSID + "\""
                        wifiConfig.preSharedKey = "\"" + networkPassword + "\""
                        val netId = wifiManager!!.addNetwork(wifiConfig)
                        wifiManager.disconnect()
                        wifiManager.enableNetwork(netId, true)
                        wifiManager.reconnect()
                        // if (isWifiConnected("\"" + deviceId + "\"")) {
                        //     doSomethingHere()
                        // }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                } else {
                    val wifiNetworkSpecifier = WifiNetworkSpecifier.Builder()
                    .setSsid(networkSSID)
                    .setWpa2Passphrase(networkPassword)
                    .build()

                    val connectivityManager = context.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
                    
                    val networkCallback = object : ConnectivityManager.NetworkCallback() {
                        override fun onUnavailable() {
                            super.onUnavailable()
                        }
                        override fun onLosing(network: Network, maxMsToLive: Int) {
                            super.onLosing(network, maxMsToLive)
                        }
                        override fun onAvailable(network: Network) {
                            super.onAvailable(network)
                            connectivityManager?.bindProcessToNetwork(network)
                        }
                        override fun onLost(network: Network) {
                            super.onLost(network)
                        }
                    }

                    val networkRequest = NetworkRequest.Builder()
                    .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                    .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                    .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
                    .setNetworkSpecifier(wifiNetworkSpecifier)
                    .build()

                    connectivityManager?.requestNetwork(networkRequest, networkCallback)

                    startActivityForResult(Intent(android.provider.Settings.ACTION_WIFI_SETTINGS), 1);
                }
            }
        }
    }
}