
#import "ProjectPluginRegistrant.h"
#import "JsEvalUtilsPlugin.h"
#import "JsonPathPlugin.h"
#import "DevicePlugin.h"

@implementation ProjectPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [JsEvalUtilsPlugin registerWithRegistrar:[registry registrarForPlugin:@"JsEvalUtilsPlugin"]];
  [JsonPathPlugin registerWithRegistrar:[registry registrarForPlugin:@"JsonPathPlugin"]];
  [DevicePlugin registerWithRegistrar:[registry registrarForPlugin:@"DevicePlugin"]];
}

@end
