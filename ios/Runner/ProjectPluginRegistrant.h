
#ifndef ProjectPluginRegistrant_h
#define ProjectPluginRegistrant_h

#import <Flutter/Flutter.h>

@interface ProjectPluginRegistrant : NSObject
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;
@end

#endif
