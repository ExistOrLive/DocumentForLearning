//
//  ZMBlockQueue.h
//  Test
//
//  Created by panzhengwei on 2019/4/30.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMNewBlockQueue : NSObject

- (instancetype) initWithCapacity:(NSUInteger) capacity;

- (void) put:(id) object;

- (id) take;

@end
