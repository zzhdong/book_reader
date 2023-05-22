package com.example.book_reader.plugin;

import android.app.Activity;
import android.content.Context;
import android.provider.Settings;
import android.view.WindowManager;
import androidx.annotation.NonNull;
import com.example.book_reader.network.EncodingDetect;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class DevicePlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    private Context applicationContext;
    private MethodChannel methodChannel;
    private Activity activity;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final DevicePlugin instance = new DevicePlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "device_plugin");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        this.onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        this.onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "brightness":
                result.success(getBrightness());
                break;
            case "setBrightness":
                double brightness = call.argument("brightness");
                WindowManager.LayoutParams layoutParams = activity.getWindow().getAttributes();
                layoutParams.screenBrightness = (float) brightness;
                activity.getWindow().setAttributes(layoutParams);
                result.success(null);
                break;
            case "isKeptOn":
                int flags = activity.getWindow().getAttributes().flags;
                result.success((flags & WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON) != 0);
                break;
            case "keepOn":
                Boolean on = call.argument("on");
                if (on) {
                    System.out.println("Keeping screen on ");
                    activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                } else {
                    System.out.println("Not keeping screen on");
                    activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
                }
                result.success(null);
                break;
            case "encodingIsUtf8":
                String filePath = call.argument("filePath");
                if("UTF-8".equals(EncodingDetect.getJavaEncode(filePath)))
                    result.success(true);
                else
                    result.success(false);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private float getBrightness() {
        float result = activity.getWindow().getAttributes().screenBrightness;
        if (result < 0) { // the application is using the system brightness
            try {
                result = Settings.System.getInt(applicationContext.getContentResolver(), Settings.System.SCREEN_BRIGHTNESS) / (float) 255;
            } catch (Settings.SettingNotFoundException e) {
                result = 1.0f;
                e.printStackTrace();
            }
        }
        return result;
    }

}