#import <UIKit/UIKit.h>
#import "Core+NSNotificationCenter.h"
#import "LocalNotifications+UNUserNotificationsCenter.h"

@implementation CoreNSNotificationCenter

+ (instancetype)instance {
  static dispatch_once_t once;
  __strong static CoreNSNotificationCenter *sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[CoreNSNotificationCenter alloc] init];
  });
  return sharedInstance;
}

- (void)observe {
  static dispatch_once_t once;
  __weak CoreNSNotificationCenter *weakSelf = self;
  dispatch_once(&once, ^{
    CoreNSNotificationCenter *strongSelf = weakSelf;
    // Application
    // ObjC -> Initialize other delegates & observers
    [[NSNotificationCenter defaultCenter]
        addObserver:strongSelf
           selector:@selector(application_onDidFinishLaunchingNotification:)
               name:UIApplicationDidFinishLaunchingNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:strongSelf
           selector:@selector(messaging_didReceiveRemoteNotification:)
               name:@"RNFBMessagingDidReceiveRemoteNotification"
             object:nil];
  });
}

+ (void)load {
  [[self instance] observe];
}

#pragma mark -
#pragma mark Application Notifications

- (void)application_onDidFinishLaunchingNotification:(nonnull NSNotification *)notification {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSDictionary *notifUserInfo =
      notification.userInfo[UIApplicationLaunchOptionsLocalNotificationKey];
  UILocalNotification *launchNotification =
      (UILocalNotification *)notification.userInfo[UIApplicationLaunchOptionsLocalNotificationKey];
  [[LocalNotificationsUNUserNotificationCenter instance]
      onDidFinishLaunchingNotification:launchNotification.userInfo];
  [[LocalNotificationsUNUserNotificationCenter instance] getInitialNotification];

  [[LocalNotificationsUNUserNotificationCenter instance] observe];
}

- (void)messaging_didReceiveRemoteNotification:(nonnull NSNotification *)notification {
  // update me with logic
}

@end
