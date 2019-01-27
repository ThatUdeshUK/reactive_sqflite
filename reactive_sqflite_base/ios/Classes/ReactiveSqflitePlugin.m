#import "ReactiveSqflitePlugin.h"
#import <reactive_sqflite/reactive_sqflite-Swift.h>

@implementation ReactiveSqflitePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftReactiveSqflitePlugin registerWithRegistrar:registrar];
}
@end
