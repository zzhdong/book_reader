package com.example.book_reader.plugin;

import android.content.Context;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class SoupPlugin implements MethodCallHandler, FlutterPlugin {

    private static final String TAG = "SoupPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final SoupPlugin instance = new SoupPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "soup_plugin");
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
            case "selectElement":
                String paramsElementText = (call.argument("elementText") == null) ? "" : call.argument("elementText").toString();
                String paramsRule = (call.argument("rule") == null) ? "" : call.argument("rule").toString();
                if (paramsElementText.equals("") || paramsRule.equals("")) {
                    result.error(TAG, "参数不能为空", null);
                } else {
                    Element el = Jsoup.parse(paramsElementText);
                    Elements resultEl = el.select(paramsRule);
                    List<String> retList = new ArrayList<String>();
                    for (Element e : resultEl) {
                        retList.add(e.outerHtml());
                    }
                    result.success(retList);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
