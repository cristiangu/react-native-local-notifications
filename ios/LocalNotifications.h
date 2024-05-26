
#import <React/RCTEventEmitter.h>
#import "UserNotifications/UserNotifications.h"
#import "react_native_local_notifications-Swift.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNLocalNotificationsSpec.h"

@interface LocalNotifications : RCTEventEmitter <NativeLocalNotificationsSpec, CoreDelegate>
#else
#import <React/RCTBridgeModule.h>

@interface LocalNotifications : RCTEventEmitter <RCTBridgeModule, CoreDelegate>
#endif

@end
