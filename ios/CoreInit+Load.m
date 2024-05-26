#import <UIKit/UIKit.h>
#import "CoreInit+Load.h"
#import "react_native_local_notifications-Swift.h"

@implementation CoreInitLoad

+ (instancetype)instance {
    static dispatch_once_t once;
    __strong static CoreInitLoad *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[CoreInitLoad alloc] init];
    });
    return sharedInstance;
}


+ (void)load {
    [[self instance] observe];
}

- (void)observe {
    static dispatch_once_t once;
    __weak CoreInitLoad *weakSelf = self;
    dispatch_once(&once, ^{
        CoreInitLoad *strongSelf = weakSelf;
        // Application
        // ObjC -> Initialize other delegates & observers
        [[NSNotificationCenter defaultCenter]
         addObserver:strongSelf
         selector:@selector(application_onDidFinishLaunchingNotification:)
         name:UIApplicationDidFinishLaunchingNotification
         object:nil];
    });
}

- (void)application_onDidFinishLaunchingNotification:(nonnull NSNotification *)notification {
    [[LocalNotificationsUNUserNotificationCenter instance] observe];
}

@end
