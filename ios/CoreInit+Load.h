#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CoreDelegate <NSObject>
@optional
- (void)didReceiveGuuCoreEvent:(NSDictionary * _Nonnull)event;
@end


@interface CoreInitLoad : NSObject

+ (_Nonnull instancetype)instance;

@end

NS_ASSUME_NONNULL_END
