#import "JsEvalUtilsPlugin.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation JsEvalUtilsPlugin

static JSContext *jsContext;
static bool isJSContextInit = false;
//static bool isHasWrite = false;

//用于输出完整长度日志
#define NSLog(format, ...) printf("TIME:%s FILE:%s(%d行) FUNCTION:%s \n %s\n\n",__TIME__, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String])

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"js_eval_plugin" binaryMessenger:[registrar messenger]];
    JsEvalUtilsPlugin* instance = [[JsEvalUtilsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"evalJs" isEqualToString:call.method]) {
        @try{
            NSString *paramsJsCode = call.arguments[@"jsCode"];
            NSString *paramsResult = call.arguments[@"result"];
            NSString *paramsBaseUrl = call.arguments[@"baseUrl"];
            NSString *paramsSearchPage = call.arguments[@"searchPage"];
            NSString *paramsSearchKey = call.arguments[@"searchKey"];
            NSString *paramsTfAjaxContentKey = call.arguments[@"tfAjaxContentKey"];
            NSString *paramsTfGetStringListKey = call.arguments[@"tfGetStringListKey"];
            NSString *paramsTfGetElementsKey = call.arguments[@"tfGetElementsKey"];
            //初始化引擎
            if(!isJSContextInit){
                jsContext = [[JSContext alloc] init];
                isJSContextInit = true;
            }
            __block bool isHasWrite = false;
            //变量赋值
            jsContext[@"result"] = paramsResult;
            jsContext[@"baseUrl"] = paramsBaseUrl;
            jsContext[@"searchPage"] = paramsSearchPage;
            jsContext[@"searchKey"] = paramsSearchKey;
            
            if(paramsTfAjaxContentKey.length > 0){
                NSArray *tfAjaxContentList = [paramsTfAjaxContentKey componentsSeparatedByString:@"-"];
                for (id str in tfAjaxContentList) {
                    NSString *key = [@"tfAjaxContent" stringByAppendingString:str];
                    jsContext[key] = call.arguments[key];
                }
            }
            if(paramsTfGetStringListKey.length > 0){
                NSArray *tfGetStringListList = [paramsTfGetStringListKey componentsSeparatedByString:@"-"];
                for (id str in tfGetStringListList) {
                    NSString *key = [@"tfGetStringList" stringByAppendingString:str];
                    jsContext[key] = call.arguments[key];
                }
            }
            if(paramsTfGetElementsKey.length > 0){
                NSArray *tfGetElementsList = [paramsTfGetElementsKey componentsSeparatedByString:@"-"];
                for (id str in tfGetElementsList) {
                    NSString *key = [@"tfGetElements" stringByAppendingString:str];
                    jsContext[key] = call.arguments[key];
                }
            }
            NSLog(@"JS调用规则：%@", paramsJsCode);
            
            //JS 调用OC函数
            jsContext[@"javaAjax"] = ^(JSValue *getUrl) {
                NSLog(@"javaAjax====== %@",getUrl);
                NSDictionary *dict = @{@"ReEvalKey":@"javaAjax", @"url": getUrl.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return getUrl;
            };
            jsContext[@"javaPut"] = ^(JSValue *key, JSValue *value) {
                NSLog(@"Put====== %@ ===== %@", key, value);
                NSDictionary *dict = @{@"ReEvalKey":@"javaPut", @"key": key.toObject, @"value": value.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return key;
            };
            jsContext[@"javaGet"] = ^(JSValue *key) {
                NSLog(@"Get====== %@",key);
                NSDictionary *dict = @{@"ReEvalKey":@"javaGet", @"key": key.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return key;
            };
            jsContext[@"javaBse64Decoder"] = ^(JSValue *base64) {
                NSDictionary *dict = @{@"ReEvalKey":@"javaBse64Decoder", @"base64": base64.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return base64;
            };
            jsContext[@"javaSetContent"] = ^(JSValue *html) {
                NSDictionary *dict = @{@"ReEvalKey":@"javaSetContent", @"html": html.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return html;
            };
            jsContext[@"javaGetString"] = ^(JSValue *rule) {
                NSDictionary *dict = @{@"ReEvalKey":@"javaGetString", @"rule": rule.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return rule;
            };
            jsContext[@"javaGetStringList"] = ^(JSValue *rule) {
                NSDictionary *dict = @{@"ReEvalKey":@"javaGetStringList", @"rule": rule.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return rule;
            };
            jsContext[@"javaGetElements"] = ^(JSValue *rule) {
                NSDictionary *dict = @{@"ReEvalKey":@"javaGetElements", @"rule": rule.toObject};
                if(!isHasWrite) result(dict);
                isHasWrite = true;
                return rule;
            };
            
            JSValue * value = [jsContext evaluateScript:paramsJsCode];
            //如果是undefined，则返回原值
            if(value == nil || [value.toString isEqual: @"undefined"]){
                NSLog(@"JS调用返回结果为空：");
                if(!isHasWrite) result(paramsResult);
            }
            else{
                if(!isHasWrite) result(value.toObject);
            }
        }
        @catch (NSException *exception){
            result(@"参数转换失败");
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
