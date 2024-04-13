
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNLocalNotificationsSpec.h"

@interface LocalNotifications : NSObject <NativeLocalNotificationsSpec>
#else
#import <React/RCTBridgeModule.h>

@interface LocalNotifications : NSObject <RCTBridgeModule>
#endif

@end
