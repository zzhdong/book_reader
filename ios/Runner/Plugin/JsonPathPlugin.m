#import "JsonPathPlugin.h"
#import "SMJJSONPath.h"

@implementation JsonPathPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel =
    [FlutterMethodChannel methodChannelWithName:@"json_path_plugin"
                                binaryMessenger:[registrar messenger]];
    JsonPathPlugin* instance = [[JsonPathPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"readData" isEqualToString:call.method]) {
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_sync(globalQueue, ^{
            NSString *paramsJson = call.arguments[@"json"];
            NSString *paramsRule = call.arguments[@"rule"];
            NSData *data = [paramsJson dataUsingEncoding:NSUTF8StringEncoding];
            if (!data)
            {
                result(@"JSON对象不存在");
                return;
            }
            NSError *error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:(0 | NSJSONReadingAllowFragments) error:&error];
            if (!jsonObject)
            {
                result([NSString stringWithFormat: @"ErrorInfo: %@, json[%@], rule[%@]", error.localizedDescription , paramsJson, paramsRule]);
                return;
            }
            NSArray *resultVal = [self resultForJSONObject:jsonObject jsonPathString:paramsRule  configuration:nil error:nil];
            result(resultVal);
        });
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (nullable id)resultForJSONObject:(id)jsonObject jsonPathString:(NSString *)jsonPathString configuration:(nullable SMJConfiguration *)configuration error:(NSError **)error
{
    SMJJSONPath *jsonPath = [[SMJJSONPath alloc] initWithJSONPathString:jsonPathString error:error];
    if (!jsonPath)
        return nil;
    if (!configuration)
        configuration = [SMJConfiguration defaultConfiguration];
    return [jsonPath resultForJSONObject:jsonObject configuration:configuration error:error];
}

@end
