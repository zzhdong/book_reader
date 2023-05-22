package com.example.book_reader.plugin;

import android.content.Context;
import com.example.book_reader.network.HttpUtils;
import com.example.book_reader.network.IHttpPostApi;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import retrofit2.Response;

public class HttpPlugin implements MethodCallHandler, FlutterPlugin {

    private static final String TAG = "HttpPlugin";
    private Context applicationContext;
    private MethodChannel methodChannel;

    /** Plugin registration. */
    public static void registerWith(PluginRegistry.Registrar registrar) {
        final HttpPlugin instance = new HttpPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        methodChannel = new MethodChannel(messenger, "http_plugin");
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
            case "postWithGBK":
                try {
                    CountDownLatch controller = new CountDownLatch(1);
                    final StringBuffer sb = new StringBuffer();
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                //拆分host和path
                                String postUrl = (call.argument("postUrl") == null) ? "" : call.argument("postUrl").toString();
                                Map<String, String> postParams = call.argument("postParams");
                                Map<String, String> postHeader = call.argument("postHeader");
                                if (postParams == null) postParams = new HashMap<String, String>();
                                if (postHeader == null) postHeader = new HashMap<String, String>();
                                String host = HttpUtils.getBaseUrl(postUrl);
                                String urlPath = postUrl.substring(host.length());
                                //GBK转码
                                Iterator<Map.Entry<String, String>> it = postParams.entrySet().iterator();
                                while (it.hasNext()) {
                                    Map.Entry<String, String> itEntry = it.next();
                                    itEntry.setValue(URLEncoder.encode(itEntry.getValue(), "gbk"));
                                }
                                //请求数据
                                Response<String> response = HttpUtils.getRetrofitString(host)
                                        .create(IHttpPostApi.class)
                                        .postMap(urlPath, postParams, postHeader).blockingFirst();
                                sb.append(response.body());
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                            controller.countDown();
                        }
                    }).start();
                    try {
                        controller.await();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    //请求数据
                    result.success(sb.toString());
                } catch (Exception e) {
                    result.error(TAG, e.getMessage(), e);
                }
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
