#import "LocalNotifications.h"
#import "react_native_local_notifications-Swift.h"

@implementation LocalNotifications
RCT_EXPORT_MODULE()

#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(scheduleNotification:
                  (JS::NativeLocalNotifications::Notification &)notification
                  trigger: (JS::NativeLocalNotifications::NotificationTrigger &)trigger
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    
    [NotificationScheduler
         scheduleNotificationWithTitle: notification.title()
         body: notification.body()
         data: (NSMutableDictionary * _Nullable) notification.data()
         scheduleId: notification.id_()
         triggerDate: [NSDate dateWithTimeIntervalSince1970: trigger.timestamp() / 1000]
    ];
    resolve(NULL);
}

#else
RCT_EXPORT_METHOD(scheduleNotification:
                  (NSDictionary *)notification
                  trigger: (NSDictionary *)trigger
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    
    [NotificationScheduler
         scheduleNotificationWithTitle: [notification objectForKey:@"title"]
         body: [notification objectForKey:@"body"]
         data: (NSMutableDictionary * _Nullable) [notification objectForKey:@"data"]
         scheduleId: [notification valueForKey:@"id"]
         triggerDate: [NSDate dateWithTimeIntervalSince1970:
                       [[trigger valueForKey:@"timestamp"] longValue] / 1000
                      ]
    ];
    resolve(NULL);
}
#endif

RCT_EXPORT_METHOD(cancelScheduledNotifications:(NSArray *)ids
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    
    [NotificationScheduler cancelScheduledNotificationsWithScheduleIds:ids];
    resolve(NULL);
}

- (void)cancelAllScheduledNotifications:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject {
    
    [NotificationScheduler cancelAllScheduledNotifications];
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
