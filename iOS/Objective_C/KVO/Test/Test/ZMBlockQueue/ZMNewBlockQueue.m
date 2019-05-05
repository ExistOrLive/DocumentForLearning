//
//  ZMBlockQueue.m
//  Test
//
//  Created by panzhengwei on 2019/4/30.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import "ZMNewBlockQueue.h"

#define DefaultCapacity 16

@interface ZMNewBlockQueue()
{
    dispatch_semaphore_t syncLock;
    
    dispatch_semaphore_t emptyConditionLock;
    
    dispatch_semaphore_t enoughConditionLock;
    
}

@property(nonatomic,strong) NSMutableArray * array;

@property(nonatomic,assign) NSUInteger capacity;

@end


@implementation ZMNewBlockQueue

- (instancetype) initWithCapacity:(NSUInteger) capacity
{
    if(self = [super init])
    {
        syncLock = dispatch_semaphore_create(1);
        emptyConditionLock = dispatch_semaphore_create(0);
        enoughConditionLock = dispatch_semaphore_create(capacity);
        
        _array = [[NSMutableArray alloc] initWithCapacity:capacity];
        _capacity = capacity;
    }
    
    return self;
}


- (instancetype) init
{
    if(self = [self initWithCapacity:DefaultCapacity])
    {
        
    }
    
    return self;
}


- (NSUInteger) size
{
    NSUInteger tmpSize = 0;
    
    dispatch_semaphore_wait(syncLock, DISPATCH_TIME_FOREVER);
    
    tmpSize = [self.array count];
    
    dispatch_semaphore_signal(syncLock);
    
    return tmpSize;
}


- (void) put:(id) object
{
    if(!object)
    {
        return;
    }
    
    long result = dispatch_semaphore_wait(enoughConditionLock, DISPATCH_TIME_FOREVER);
    
    if(!result)
    {
        NSLog(@"Thread[%@] put wait %@",[NSThread currentThread],object);
    }
    
    NSLog(@"Thread[%@] put start %@",[NSThread currentThread],object);
    
    dispatch_semaphore_wait(syncLock, DISPATCH_TIME_FOREVER);
    
    [_array insertObject:object atIndex:0];
    
    dispatch_semaphore_signal(syncLock);
    
    NSLog(@"Thread[%@] put end %@",[NSThread currentThread],object);
    
    dispatch_semaphore_signal(emptyConditionLock);
    
    NSLog(@"put count[%ld]",self.size);
}

- (id) take
{
    id object = nil;
    
    long result = dispatch_semaphore_wait(emptyConditionLock, DISPATCH_TIME_FOREVER);
    
    if(!result)
    {
        NSLog(@"Thread[%@] take wait",[NSThread currentThread]);
    }
    
    NSLog(@"Thread[%@] take start",[NSThread currentThread]);
    
    dispatch_semaphore_wait(syncLock, DISPATCH_TIME_FOREVER);
    
    object = [_array lastObject];
    
    [_array removeLastObject];
    
    dispatch_semaphore_signal(syncLock);
    
    NSLog(@"Thread[%@] take end %@",[NSThread currentThread],object);
    
    dispatch_semaphore_signal(enoughConditionLock);
    
     NSLog(@"take count[%ld]",self.size);
    
    return object;
    
}

@end


