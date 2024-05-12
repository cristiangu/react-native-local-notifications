//
//  Core.h
//  Pods
//
//  Created by Cristian Gutu on 11.05.2024.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN


static NSString *kGuuUserInfoNotification = @"__guulabs_notification";
static NSString *kGuuUserInfoTrigger = @"__guulabs_trigger";

typedef NS_ENUM(NSInteger, CoreEventType) {
  CoreEventTypeDismissed = 0,
  CoreEventTypeDelivered = 3,
  CoreEventTypeTriggerNotificationCreated = 7,
};

typedef void (^guuMethodNSDictionaryBlock)(NSError *_Nullable, NSDictionary *_Nullable);

@class Core;

@protocol CoreDelegate <NSObject>
@optional
- (void)didReceiveGuuCoreEvent:(NSDictionary *_Nonnull)event;
@end


@interface Core : NSObject

+ (NSDictionary *)parseUNNotificationRequest:(UNNotificationRequest *)request;

+ (void)setCoreDelegate:(id<CoreDelegate>)coreDelegate;

+ (void)getInitialNotification:(guuMethodNSDictionaryBlock)block;

@end

NS_ASSUME_NONNULL_END
