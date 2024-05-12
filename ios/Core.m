//
//  Core.m
//  react-native-local-notifications
//
//  Created by Cristian Gutu on 11.05.2024.
//

#import <Foundation/Foundation.h>
#import "Core.h"
#import "CoreDelegateHolder.h"
#import "LocalNotifications+UNUserNotificationsCenter.h"

@implementation Core

+ (void)setCoreDelegate:(id<CoreDelegate>)coreDelegate {
  [CoreDelegateHolder instance].delegate = coreDelegate;
}

+ (NSMutableDictionary *)parseDataFromUserInfo:(NSDictionary *)userInfo {
  NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
  for (id key in userInfo) {
    // build data dict from remaining keys but skip keys that shouldn't be included in data
    if ([key isEqualToString:@"aps"] || [key hasPrefix:@"gcm."] || [key hasPrefix:@"google."] ||
        // guu or guu_options
        [key hasPrefix:@"guu"] ||
        // fcm_options
        [key hasPrefix:@"fcm"]) {
      continue;
    }
    data[key] = userInfo[key];
  }

  return data;
}


+ (NSMutableDictionary *)parseUNNotificationContent:(UNNotificationContent *)content {
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  NSMutableDictionary *iosDict = [NSMutableDictionary dictionary];

  dictionary[@"subtitle"] = content.subtitle;
  dictionary[@"body"] = content.body;
  dictionary[@"data"] = [content.userInfo mutableCopy];

  // title
  if (content.title != nil) {
    dictionary[@"title"] = content.title;
  }

  // subtitle
  if (content.subtitle != nil) {
    dictionary[@"subtitle"] = content.subtitle;
  }

  // body
  if (content.body != nil) {
    dictionary[@"body"] = content.body;
  }

  iosDict[@"badgeCount"] = content.badge;

  // categoryId
  if (content.categoryIdentifier != nil) {
    iosDict[@"categoryId"] = content.categoryIdentifier;
  }

  // launchImageName
  if (content.launchImageName != nil) {
    iosDict[@"launchImageName"] = content.launchImageName;
  }

  // threadId
  if (content.threadIdentifier != nil) {
    iosDict[@"threadId"] = content.threadIdentifier;
  }

  // targetContentId
  if (@available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, *)) {
    if (content.targetContentIdentifier != nil) {
      iosDict[@"targetContentId"] = content.targetContentIdentifier;
    }
  }

  if (content.attachments != nil) {
    // TODO: parse attachments
  }

  // sound
  if (content.sound != nil) {
    if ([content.sound isKindOfClass:[NSString class]]) {
      iosDict[@"sound"] = content.sound;
    } else if ([content.sound isKindOfClass:[NSDictionary class]]) {
      NSDictionary *soundDict = content.sound;
      NSMutableDictionary *notificationIOSSound = [[NSMutableDictionary alloc] init];

      // ios.sound.name String
      if (soundDict[@"name"] != nil) {
        notificationIOSSound[@"name"] = soundDict[@"name"];
      }

      // sound.critical Boolean
      if (soundDict[@"critical"] != nil) {
        notificationIOSSound[@"critical"] = soundDict[@"critical"];
      }

      // ios.sound.volume Number
      if (soundDict[@"volume"] != nil) {
        notificationIOSSound[@"volume"] = soundDict[@"volume"];
      }

      // ios.sound
      iosDict[@"sound"] = notificationIOSSound;
    }
  }

  dictionary[@"ios"] = iosDict;
  return dictionary;
}


/**
 * Parse UNNotificationRequest to NSDictionary
 *
 * @param request UNNotificationRequest
 */
+ (NSMutableDictionary *)parseUNNotificationRequest:(UNNotificationRequest *)request {
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

  dictionary = [self parseUNNotificationContent:request.content];
  dictionary[@"id"] = request.identifier;

  NSDictionary *userInfo = request.content.userInfo;

  // Check for remote details
  if ([request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    NSMutableDictionary *remote = [NSMutableDictionary dictionary];

    remote[@"messageId"] = userInfo[@"gcm.message_id"];
    remote[@"senderId"] = userInfo[@"google.c.sender.id"];

    if (userInfo[@"aps"] != nil) {
      remote[@"mutableContent"] = userInfo[@"aps"][@"mutable-content"];
      remote[@"contentAvailable"] = userInfo[@"aps"][@"content-available"];
    }

    dictionary[@"remote"] = remote;
  }

  dictionary[@"data"] = [self parseDataFromUserInfo:userInfo];

  return dictionary;
}

+ (void)getInitialNotification:(guuMethodNSDictionaryBlock)block {
  [LocalNotificationsUNUserNotificationCenter instance].initialNotificationBlock = block;
  [[LocalNotificationsUNUserNotificationCenter instance] getInitialNotification];
}

@end
