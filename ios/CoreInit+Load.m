#import <UIKit/UIKit.h>
#import "CoreInit+Load.h"
#import "react_native_local_notifications-Swift.h"

@implementation CoreInitLoad

+ (void)load {
    [[CoreInit instance] setupListeners];
}

@end
