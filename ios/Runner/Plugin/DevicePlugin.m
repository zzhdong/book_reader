#import "DevicePlugin.h"
#import "uchardet.h"
#import "FileOperation.h"

@implementation DevicePlugin

static NSString *encodeTypeStr;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"device_plugin"
                                     binaryMessenger:[registrar messenger]];
    DevicePlugin* instance = [[DevicePlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"brightness" isEqualToString:call.method]) {
        result([NSNumber numberWithFloat:[UIScreen mainScreen].brightness]);
    }
    else if ([@"setBrightness" isEqualToString:call.method]) {
        NSNumber *brightness = call.arguments[@"brightness"];
        [[UIScreen mainScreen] setBrightness:brightness.floatValue];
        result(nil);
    }
    else if ([@"isKeptOn" isEqualToString:call.method]) {
        bool isIdleTimerDisabled =  [[UIApplication sharedApplication] isIdleTimerDisabled];
        result([NSNumber numberWithBool:isIdleTimerDisabled]);
    }
    else if ([@"keepOn" isEqualToString:call.method]) {
        NSNumber *b = call.arguments[@"on"];
        [[UIApplication sharedApplication] setIdleTimerDisabled:b.boolValue];
    }
    else if ([@"encodingIsUtf8" isEqualToString:call.method]) {
        NSString *filePath = call.arguments[@"filePath"];
        result([NSNumber numberWithBool:[self encodingIsUtf8:filePath]]);
    }
    else if ([@"writeFileByEncode" isEqualToString:call.method]) {
        NSString *filePath = call.arguments[@"filePath"];
        NSString *encode = call.arguments[@"encode"];
        NSString *fileContent;
        if([encode isEqualToString:@"gbk"])
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        else
            fileContent = [NSString stringWithContentsOfFile:filePath encoding:kCFStringEncodingGB_18030_2000 error:nil];
        
        [FileOperation createFileAtPath:filePath overwrite:true];
        if ([FileOperation writeFileAtPath:filePath content:fileContent encode:encode]) {
            NSLog(@"文件内容写入成功");
            NSLog(@"写入内容:%@",fileContent);
        }else{
            NSLog(@"文件内容写入失败");
        }
        result([NSNumber numberWithBool:true]);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

/**
 当前txt文件编码格式
 @param strTxtPath 路径
 @return 是否检测出编码格式   0：检测出 其余：发生错误无法检测出编码格式
 */
- (int)txtEncoding:(const char *)strTxtPath {
    FILE *file;
    char buf[NUMBER_OF_SAMPLES];
    size_t len;
    uchardet_t ud;
    /* 打开被检测文本文件，并读取一定数量的样本字符 */
    file = fopen(strTxtPath, "rt");
    if (file==NULL) {
        printf("文件打开失败！\n");
        return 1;
    }
    len = fread(buf, sizeof(char), NUMBER_OF_SAMPLES, file);
    fclose(file);
    ud = uchardet_new();
    if (uchardet_handle_data(ud, buf, len) != 0) {
        printf("分析编码失败！\n");
        return -1;
    }
    uchardet_data_end(ud);
    encodeTypeStr = [[NSString alloc] initWithCString:uchardet_get_charset(ud) encoding:NSUTF8StringEncoding];
    uchardet_delete(ud);
    return 0;
}

- (BOOL)encodingIsUtf8:(NSString *)path {
    int result = [self txtEncoding:[path UTF8String]];
    if (result == 0) {
        NSLog(@"文本的编码方式是%@", encodeTypeStr);
        if ([encodeTypeStr isEqualToString:@"GB18030"]) {
            return false;
        } else if ([encodeTypeStr isEqualToString:@"GBK"]) {
            return false;
        } else if ([encodeTypeStr isEqualToString:@"GB2312"]) {
            return false;
        } else if ([encodeTypeStr isEqualToString:@"ASCII"]) {
            return false;
        } else if ([encodeTypeStr isEqualToString:@"UTF-8"]) {
            return true;
        } else if ([encodeTypeStr isEqualToString:@"UTF-16"]) {
            return true;
        }
    }
    return true;
}

@end

