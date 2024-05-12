#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
//#import "NotifeeCore.h"


typedef void (^guuLabsMethodNSDictionaryBlock)(NSError *_Nullable, NSDictionary *_Nullable);

NS_ASSUME_NONNULL_BEGIN

@interface LocalNotificationsUNUserNotificationCenter : NSObject <UNUserNotificationCenterDelegate>

@property(nonatomic, nullable, weak) id<UNUserNotificationCenterDelegate> originalDelegate;

@property(strong, nullable) NSDictionary *initialNotification;
@property bool initialNotificationGathered;
@property(nullable) guuLabsMethodNSDictionaryBlock initialNotificationBlock;
@property NSString *initialNoticationID;
@property NSString *notificationOpenedAppID;

+ (_Nonnull instancetype)instance;

- (void)observe;

- (nullable NSDictionary *)getInitialNotification;

- (void)onDidFinishLaunchingNotification:(NSDictionary *)notification;

//+ (UNMutableNotificationContent *)buildNotificationContent:(NSDictionary *)notification;

@end

NS_ASSUME_NONNULL_END
