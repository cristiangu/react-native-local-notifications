#import "LocalNotifications.h"
#import "react_native_local_notifications-Swift.h"

@implementation LocalNotifications
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
//RCT_EXPORT_METHOD(multiply:(double)a
//                  b:(double)b
//                  resolve:(RCTPromiseResolveBlock)resolve
//                  reject:(RCTPromiseRejectBlock)reject)
//{
//    NSNumber *result = @(a * b);
//    
//    [NotificationScheduler 
//     scheduleNotificationWithTitle:@"Test title"
//     body:@"Test body"
//     triggerDate:[NSDate dateWithTimeIntervalSinceNow:60]
//    ];
//
//    resolve(result);
//}


RCT_EXPORT_METHOD(scheduleNotification:
                  (JS::NativeLocalNotifications::Notification &)notification
                  trigger: (JS::NativeLocalNotifications::NotificationTrigger &)trigger
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
//    [NotifeeCore createTriggerNotification:notification withTrigger:trigger withBlock:^(NSError *_Nullable error) {
//        
//      [self resolve:resolve orReject:reject promiseWithError:error orResult:nil];
//    }];
    resolve(NULL);
  }

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeLocalNotificationsSpecJSI>(params);
}
#endif

@end
