package com.example.caralapp

import android.content.Context;
import androidx.multidex.MultiDex;
import co.pushe.plus.flutter.PusheFlutterPlugin;
import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;

class MyApp : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    // در صورتی که مالتی دکس را فعال کرده‌اید این تابع را نیز قرار دهید

    override protected fun attachBaseContext(base: Context?) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }


    override fun onCreate() {
        super.onCreate()
        //PusheFlutterPlugin.setDebugMode(true) // فعال‌سازی دیباگ مد برای چاپ اطلاعات بیشتر در کنسول
        PusheFlutterPlugin.initialize(this)
    }


    override fun registerWith(registry: PluginRegistry) {
        // یکی از خطوط زیر
        PusheFlutterPlugin.registerWith(registry) // FlutterEmbedding v2
        //GeneratedPluginRegistrant.registerWith(registry) // FlutterEmbedding v1
    }
}
