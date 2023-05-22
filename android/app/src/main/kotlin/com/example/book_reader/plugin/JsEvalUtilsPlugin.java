package com.example.book_reader.plugin;

import android.content.Context;
import com.example.book_reader.common.GlobalVal;
import com.example.book_reader.common.LogUtil;
import java.util.HashMap;
import javax.script.SimpleBindings;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class JsEvalUtilsPlugin implements MethodCallHandler, FlutterPlugin {

    private static final String TAG = "JsEvalUtilsPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;
    private Result tmpResult;
    private Boolean hasWrite = false;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final JsEvalUtilsPlugin instance = new JsEvalUtilsPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "js_eval_plugin");
        methodChannel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        applicationContext = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        tmpResult = result;
        switch (call.method) {
            case "evalJs":
                String paramsJsCode = (call.argument("jsCode") == null) ? "" : call.argument("jsCode").toString();
                Object paramsResult = call.argument("result");
                String paramsBaseUrl = (call.argument("baseUrl") == null) ? "" : call.argument("baseUrl").toString();
                String paramsSearchPage = (call.argument("searchPage") == null) ? "" : call.argument("searchPage").toString();
                String paramsSearchKey = (call.argument("searchKey") == null) ? "" : call.argument("searchKey").toString();
                String paramsTfAjaxContentKey = (call.argument("tfAjaxContentKey") == null) ? "" : call.argument("tfAjaxContentKey").toString();
                hasWrite = false;

                SimpleBindings bindings = new SimpleBindings();
                bindings.put("java", this);
                bindings.put("result", paramsResult);
                bindings.put("baseUrl", paramsBaseUrl);
                bindings.put("searchPage", paramsSearchPage);
                bindings.put("searchKey", paramsSearchKey);

                String[] tfAjaxContentList = paramsTfAjaxContentKey.split("-");
                for (String str : tfAjaxContentList) {
                    String key = "tfAjaxContent" + str;
                    String value = (call.argument(key) == null) ? "" : call.argument(key).toString();
                    bindings.put(key, value);
                }
                try {
                    Object retObj = GlobalVal.SCRIPT_ENGINE.eval(paramsJsCode, bindings);
                    if (!hasWrite) result.success(retObj);
                } catch (Exception e) {
                    if (!hasWrite) result.error(TAG, e.getMessage(), e);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }


    public String ajax(String postUrl) {
        LogUtil.i(TAG, "Ajax =================== " + postUrl);
        HashMap<String, String> map = new HashMap<String, String>();
        map.put("ReEvalKey", "javaAjax");
        map.put("url", postUrl);
        if(!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String put(String key, String value) {
        LogUtil.i(TAG, "Put =================== " + key + " =========== " + value);
        HashMap<String, String> map = new HashMap<String, String>();
        map.put("ReEvalKey", "javaPut");
        map.put("key", key);
        map.put("value", value);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String get(String key) {
        LogUtil.i(TAG, "Get =================== " + key);
        HashMap<String, String> map = new HashMap<String, String>();
        map.put("ReEvalKey", "javaGet");
        map.put("key", key);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String base64Decoder(String base64) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("ReEvalKey", "javaBase64Decoder");
        map.put("base64", base64);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String setContent(Object html) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("ReEvalKey", "javaSetContent");
        map.put("html", html);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String getString(String rule) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("ReEvalKey", "javaGetString");
        map.put("rule", rule);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String getStringList(String rule) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("ReEvalKey", "javaGetStringList");
        map.put("rule", rule);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }

    public String getElements(String rule) {
        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("ReEvalKey", "javaGetElements");
        map.put("rule", rule);
        if (!hasWrite) tmpResult.success(map);
        hasWrite = true;
        return "";
    }
}


