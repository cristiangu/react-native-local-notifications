
#import <React/RCTEventEmitter.h>
#import "Core.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNLocalNotificationsSpec.h"

@interface LocalNotifications : RCTEventEmitter <NativeLocalNotificationsSpec, CoreDelegate>
#else
#import <React/RCTBridgeModule.h>

@interface LocalNotifications : RCTEventEmitter <RCTBridgeModule, CoreDelegate>
#endif

@end
