package com.example.book_reader

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import com.example.book_reader.plugin.CustomPluginRegistrant
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        //注册插件
        CustomPluginRegistrant.registerWith(flutterEngine)
    }
}
