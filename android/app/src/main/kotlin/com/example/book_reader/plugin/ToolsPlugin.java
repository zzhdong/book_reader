package com.example.book_reader.plugin;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.MobileAds;
import com.kaopiz.kprogresshud.KProgressHUD;
import com.zqc.opencc.android.lib.ChineseConverter;
import com.zqc.opencc.android.lib.ConversionType;
import org.jsoup.Jsoup;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URL;
import java.util.Enumeration;
import java.util.regex.Pattern;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class ToolsPlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    private static final String TAG = "ToolsPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;
    private Activity activity;
    private KProgressHUD hud;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final ToolsPlugin instance = new ToolsPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "tools_plugin");
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
    public void onMethodCall(MethodCall call, final Result result) {
        switch (call.method) {
            case "showLoading":
                if (hud == null) {
                    hud = KProgressHUD.create(activity).setStyle(KProgressHUD.Style.SPIN_INDETERMINATE);
                    hud.show();
                }
                break;
            case "hideLoading":
                if (hud != null) {
                    hud.dismiss();
                    hud = null;
                }
                break;
            case "setAdMuted":
                //向admob报告静音，会导致广告减少
                //MobileAds.setAppMuted(true);
                MobileAds.setAppVolume(0.0f);
                result.success("");
                break;
            case "setAdUnMuted":
                MobileAds.setAppMuted(false);
                MobileAds.setAppVolume(1.0f);
                result.success("");
                break;
            case "getAbsoluteURL":
                String paramsBaseURL = (call.argument("baseURL") == null) ? "" : call.argument("baseURL").toString();
                String paramsRelativePath = (call.argument("relativePath") == null) ? "" : call.argument("relativePath").toString();
                try {
                    URL absoluteUrl = new URL(paramsBaseURL);
                    URL parseUrl = new URL(absoluteUrl, paramsRelativePath);
                    paramsRelativePath = parseUrl.toString();
                    result.success(paramsRelativePath);
                } catch (Exception e) {
                    result.success(paramsRelativePath);
                }
                break;
            case "formatHtml":
                String paramsHtml = (call.argument("html") == null) ? "" : call.argument("html").toString();
                try {
                    result.success(Jsoup.parse(paramsHtml).outerHtml());
                } catch (Exception e) {
                    result.success(paramsHtml);
                }
                break;
            case "toSimplifiedChinese":
                String paramsContent = (call.argument("content") == null) ? "" : call.argument("content").toString();
                try {
                    result.success(ChineseConverter.convert(paramsContent, ConversionType.T2S, applicationContext));
                } catch (Exception e) {
                    result.success(paramsContent);
                }
                break;
            case "toTraditionalChinese":
                paramsContent = (call.argument("content") == null) ? "" : call.argument("content").toString();
                try {
                    result.success(ChineseConverter.convert(paramsContent, ConversionType.S2T, applicationContext));
                } catch (Exception e) {
                    result.success(paramsContent);
                }
                break;
            case "getIpAdress":
                InetAddress inetAddress = getLocalIPAddress();
                if(inetAddress == null)
                    result.success(inetAddress.getHostAddress());
                else
                    result.success("");
                break;
            case "getIpV6Adress":
                inetAddress = getLocalIPAddress();
                if(inetAddress == null)
                    result.success(inetAddress.getHostAddress());
                else
                    result.success("");
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private static final Pattern IPV4_PATTERN = Pattern.compile(
            "^(" + "([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}" +
                    "([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$");

    public static boolean isIPv4Address(String input) {
        return IPV4_PATTERN.matcher(input).matches();
    }

    public static InetAddress getLocalIPAddress() {
        Enumeration<NetworkInterface> enumeration = null;
        try {
            enumeration = NetworkInterface.getNetworkInterfaces();
        } catch (SocketException e) {
            e.printStackTrace();
        }
        if (enumeration != null) {
            while (enumeration.hasMoreElements()) {
                NetworkInterface nif = enumeration.nextElement();
                Enumeration<InetAddress> inetAddresses = nif.getInetAddresses();
                if (inetAddresses != null) {
                    while (inetAddresses.hasMoreElements()) {
                        InetAddress inetAddress = inetAddresses.nextElement();
                        if (!inetAddress.isLoopbackAddress() && isIPv4Address(inetAddress.getHostAddress())) {
                            return inetAddress;
                        }
                    }
                }
            }
        }
        return null;
    }
}
