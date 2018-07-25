
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <React/RCTConvert.h>
#import "PlugpagLib/PlugPag.h"

@interface RNPlugpag : NSObject <RCTBridgeModule>
@end
