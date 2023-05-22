package com.example.book_reader.plugin;

import android.content.Context;

import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.ReadContext;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class JsonPathPlugin implements MethodCallHandler, FlutterPlugin {

    private static final String TAG = "JsonPathPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final JsonPathPlugin instance = new JsonPathPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "json_path_plugin");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        switch (call.method) {
            case "readData":
                String paramsJson = (call.argument("json") == null) ? "" : call.argument("json").toString();
                String paramsRule = (call.argument("rule") == null) ? "" : call.argument("rule").toString();
                ReadContext ctx = JsonPath.parse(paramsJson);
                result.success(ctx.read(paramsRule));
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
