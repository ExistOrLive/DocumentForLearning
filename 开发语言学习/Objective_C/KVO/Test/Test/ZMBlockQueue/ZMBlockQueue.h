//
//  ZMBlockQueue.h
//  Test
//
//  Created by zhumeng on 2018/11/22.
//  Copyright © 2018年 ZM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  ZMBlockQueue
 *  利用pthread_mutex_t 实现的简单阻塞队列
 *  使用 生产者线程数量 和 消费者线程数量差异不大的情况，如果两者数量差距较大，就无法保证有效的capacity和线程阻塞
 **/

@interface ZMBlockQueue : NSObject

@property(nonatomic,readonly) NSUInteger capacity;

@property(nonatomic,readonly) NSUInteger size;

- (instancetype) initWithCapacity:(NSUInteger) capacity;

- (void) put:(id) value;

- (id) take;


@end
