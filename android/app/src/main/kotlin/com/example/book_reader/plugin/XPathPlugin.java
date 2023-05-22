package com.example.book_reader.plugin;

import android.content.Context;

import org.seimicrawler.xpath.JXDocument;
import org.seimicrawler.xpath.JXNode;

import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class XPathPlugin implements MethodChannel.MethodCallHandler, FlutterPlugin {

    private static final String TAG = "XPathPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final XPathPlugin instance = new XPathPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "xpath_plugin");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(MethodCall call, final MethodChannel.Result result) {
        switch (call.method) {
            case "selectNodesXml":
                String paramsHtml = (call.argument("html") == null) ? "" : call.argument("html").toString();
                String paramsRule = (call.argument("rule") == null) ? "" : call.argument("rule").toString();
                try {
                    JXDocument jxDocument = JXDocument.create(paramsHtml);
                    List<JXNode> nodeList = jxDocument.selN(paramsRule);
                    List<String> strList = new ArrayList<String>();
                    for (JXNode node : nodeList) {
                        strList.add(node.value().toString());
                    }
                    result.success(strList);
                } catch (Exception e) {
                    result.success(paramsHtml);
                }
                break;
            case "selectNodesValue":
                paramsHtml = (call.argument("html") == null) ? "" : call.argument("html").toString();
                paramsRule = (call.argument("rule") == null) ? "" : call.argument("rule").toString();
                try {
                    JXDocument jxDocument = JXDocument.create(paramsHtml);
                    List<JXNode> nodeList = jxDocument.selN(paramsRule);
                    List<String> strList = new ArrayList<String>();
                    for (JXNode node : nodeList) {
                        strList.add(String.valueOf(node));
                    }
                    result.success(strList);
                } catch (Exception e) {
                    result.success(paramsHtml);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}