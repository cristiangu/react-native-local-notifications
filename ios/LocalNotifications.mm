#import "LocalNotifications.h"
#import <React/RCTUtils.h>
#import <UIKit/UIKit.h>
#import "UserNotifications/UserNotifications.h"
#import "react_native_local_notifications-Swift.h"

static NSString *kReactNativeGuuNotificationEvent = @"app.guulabs.notification-event";

@implementation LocalNotifications {
    bool hasListeners;
    NSMutableArray *pendingCoreEvents;
}
RCT_EXPORT_MODULE()

NSString *TAG = @"[react-native-local-notifications]";

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (id)init {
    if (self = [super init]) {
        pendingCoreEvents = [[NSMutableArray alloc] init];
        [CoreGuu setCoreDelegate: self];
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents {
    return @[ kReactNativeGuuNotificationEvent ];
}

- (void)startObserving {
    hasListeners = YES;
    for (NSDictionary *eventBody in pendingCoreEvents) {
        [self sendEvent:eventBody];
    }
    [pendingCoreEvents removeAllObjects];
}

- (void)stopObserving {
    hasListeners = NO;
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

- (void)sendEvent:(NSDictionary *_Nonnull)eventBody {
    dispatch_after(
                   dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       if (RCTRunningInAppExtension() ||
                           [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                           //[self sendEventWithName:kReactNativeGuuNotificationBackgroundEvent body:eventBody];
                       } else {
                           [self sendEventWithName:kReactNativeGuuNotificationEvent body:eventBody];
                       }
                   });
}

- (void)didReceiveGuuCoreEvent:(NSDictionary *_Nonnull)event {
    if (hasListeners) {
        [self sendEvent:event];
    } else {
        [pendingCoreEvents addObject:event];
    }
}

#ifdef RCT_NEW_ARCH_ENABLED
RCT_EXPORT_METHOD(scheduleNotification:
                  (JS::NativeLocalNotifications::Notification &)notification
                  trigger: (JS::NativeLocalNotifications::NotificationTrigger &)trigger
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    
    if(notification.title() == NULL) {
        NSString *message = [NSString stringWithFormat:@"%@ Title prop is missing.", TAG];
        reject(@"error", message, NULL);
        return;
    }
    
    NSString *scheduleId = [NotificationScheduler
                            scheduleNotificationWithTitle: notification.title()
                            body: notification.body()
                            data: (NSMutableDictionary * _Nullable) notification.data()
                            scheduleId: notification.id_()
                            triggerDate: [NSDate dateWithTimeIntervalSince1970: trigger.timestamp() / 1000]
    ];
    
    resolve(scheduleId);
}



RCT_EXPORT_METHOD(getInitialNotification:
                  (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject) {
    [CoreGuu getInitialNotification:^(NSError *_Nullable error, NSDictionary *settings) {
        if(error != nil) {
            reject(@"error", error.description, error);
        } else {
            resolve(settings);
        }
    }];
}

#else
RCT_EXPORT_METHOD(scheduleNotification:
                  (NSDictionary *)notification
                  trigger: (NSDictionary *)trigger
                  resolve: (RCTPromiseResolveBlock) resolve
                  reject: (RCTPromiseRejectBlock) reject)
{
    
    
    if(notification == NULL || trigger == NULL) {
        NSString *message = [NSString stringWithFormat:@"%@ Missing notification or trigger config.", TAG];
        reject(@"error", message, NULL);
        return;
    }
    
    NSString *title = [notification objectForKey:@"title"];
    if(title == NULL) {
        NSString *message = [NSString stringWithFormat:@"%@ Title prop is missing.", TAG];
        reject(@"error", message, NULL);
        return;
    }
    
    NSString *scheduleId = [NotificationScheduler
                            scheduleNotificationWithTitle: title
                            body: [notification objectForKey:@"body"]
                            data: (NSMutableDictionary * _Nullable) [notification objectForKey:@"data"]
                            scheduleId: [notification valueForKey:@"id"]
                            triggerDate: [NSDate dateWithTimeIntervalSince1970:
                                              [[trigger valueForKey:@"timestamp"] longValue] / 1000
                                         ]
    ];
    resolve(scheduleId);
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
