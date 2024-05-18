
/**
 * Copyright (c) 2016-present Invertase Limited & Contributors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this library except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import <Foundation/Foundation.h>
#import "Core.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDelegateHolder : NSObject

@property(nonatomic, weak) id<CoreDelegate> delegate;
@property(atomic, strong) NSMutableArray<NSDictionary *> *pendingEvents;

+ (instancetype)instance;

- (void)didReceiveGuuCoreEvent:(NSDictionary *)event;

@end

NS_ASSUME_NONNULL_END