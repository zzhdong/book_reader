package com.example.book_reader.plugin;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry;

@Keep
public final class CustomPluginRegistrant {

    public static void registerWith(@NonNull FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new JsEvalUtilsPlugin());
        flutterEngine.getPlugins().add(new SoupPlugin());
        flutterEngine.getPlugins().add(new JsonPathPlugin());
        flutterEngine.getPlugins().add(new XPathPlugin());
        flutterEngine.getPlugins().add(new HttpPlugin());
        flutterEngine.getPlugins().add(new ToolsPlugin());
        flutterEngine.getPlugins().add(new DevicePlugin());
//        ShimPluginRegistry shimPluginRegistry = new ShimPluginRegistry(flutterEngine);
//        ToolsPlugin.registerWith(shimPluginRegistry.registrarFor("com.example.book_reader.plugin.ToolsPlugin"));
//        DevicePlugin.registerWith(shimPluginRegistry.registrarFor("com.example.book_reader.plugin.DevicePlugin"));
    }
}
