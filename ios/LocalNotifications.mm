#import "LocalNotifications.h"
#import <React/RCTUtils.h>
#import <UIKit/UIKit.h>
#import "Core.h"
#import "react_native_local_notifications-Swift.h"

static NSString *kReactNativeNotifeeNotificationEvent = @"app.guulabs.notification-event";



@implementation LocalNotifications
RCT_EXPORT_MODULE()

struct {
    unsigned int didReceiveNotificationEvent : 1;
  } delegateRespondsTo;

bool hasListeners;
NSMutableArray *pendingCoreEvents;
NSString *TAG = @"[react-native-local-notifications]";


- (id)init {
  if (self = [super init]) {
    pendingCoreEvents = [[NSMutableArray alloc] init];
    [Core setCoreDelegate: self];
  }
  return self;
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

- (NSArray<NSString *> *)supportedEvents {
  return @[ kReactNativeNotifeeNotificationEvent ];
}

- (void)sendEvent:(NSDictionary *_Nonnull)eventBody {
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (RCTRunningInAppExtension() ||
            [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
          //[self sendEventWithName:kReactNativeNotifeeNotificationBackgroundEvent body:eventBody];
        } else {
          [self sendEventWithName:kReactNativeNotifeeNotificationEvent body:eventBody];
        }
      });
}

- (void)didReceiveNotifeeCoreEvent:(NSDictionary *_Nonnull)event {
  if (hasListeners) {
    [self sendEvent:event];
  } else {
    [pendingCoreEvents addObject:event];
  }
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
  return YES;
}



@end
