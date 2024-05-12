//
//  Core.h
//  Pods
//
//  Created by Cristian Gutu on 11.05.2024.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN


static NSString *kNotifeeUserInfoNotification = @"__guulabs_notification";
static NSString *kNotifeeUserInfoTrigger = @"__guulabs_trigger";

typedef NS_ENUM(NSInteger, CoreEventType) {
  CoreEventTypeDismissed = 0,
  CoreEventTypeDelivered = 3,
  CoreEventTypeTriggerNotificationCreated = 7,
};

@class Core;

@protocol CoreDelegate <NSObject>
@optional
- (void)didReceiveNotifeeCoreEvent:(NSDictionary *_Nonnull)event;
@end


@interface Core : NSObject

+ (NSDictionary *)parseUNNotificationRequest:(UNNotificationRequest *)request;

+ (void)setCoreDelegate:(id<CoreDelegate>)coreDelegate;

@end

NS_ASSUME_NONNULL_END
