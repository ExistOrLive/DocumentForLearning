
//
//  ZMBlockQueue.m
//  Test
//
//  Created by zhumeng on 2018/11/22.
//  Copyright © 2018年 ZM. All rights reserved.
//

/**
 * 阻塞队列实现原理
 * 1、 首先需要一个互斥锁实现消费者线程和生产者线程对缓存队列的互斥访问
 * 2、 另外 当缓存队列为空时，消费者线程等待 缓存队列满时，生产者线程等待
 * 3、 当生产者线程向缓存队列中插入一个元素，需要唤醒等待的消费者线程
 * 4、 当消费者线程从缓存队列中取出一个元素，需要唤醒等待的生产者线程
 *
 *
 *  pthread_cond_t 是一个条件， pthread_mutex_t 是一个同步锁， 两者可以组成一个条件锁； 条件锁要保证信号量的互斥访问
 *  一个pthread_cond_t 对应一个信号量
 *  pthread_mutex_t 要保证信号量的修改及访问 和 pthread_cond_wait 在同一个临界区
 **/

#import "ZMBlockQueue.h"
#include <pthread.h>

#define DefaultCapacity 16


@interface ZMBlockQueue()
{
    pthread_mutex_t syncMutex;               // 同步锁，用于对数组的互斥访问
    
    pthread_cond_t putCondition;             // 条件锁，在数组容量满时，wait
    pthread_mutex_t putMutex;                // 保证 put线程对信号量的同步访问
    
    pthread_cond_t takeCondition;            // 条件锁， 在数组为空时， wait
    pthread_mutex_t takeMutex;               // 保证 take线程对信号量的同步访问
    
    
}

@property(nonatomic,strong) NSMutableArray * queue;

@end


@implementation ZMBlockQueue

- (instancetype) initWithCapacity:(NSUInteger) capacity
{
    if(self = [super init])
    {
        _capacity = capacity;
        _queue = [[NSMutableArray alloc] init];
    
        /**
         *
         * 设置为默认互斥锁，当一个线程获取到锁后，其余线程必须在请求锁时，形成一个等待对列；当释放锁后，其余线程按优先级取锁； 默认不能够嵌套
         **/
        pthread_mutex_init(&syncMutex,NULL);
        
        pthread_cond_init(&putCondition, NULL);
        pthread_mutex_init(&putMutex, NULL);
        
        pthread_cond_init(&takeCondition, NULL);
        pthread_mutex_init(&takeMutex, NULL);
        
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
    
    pthread_mutex_lock(&syncMutex);
    
    tmpSize = [self.queue count];
    
    pthread_mutex_unlock(&syncMutex);
    
    return tmpSize;
}


- (void) put:(id) value
{
    if(!value)
    {
        return;
    }
    
    pthread_mutex_lock(&putMutex);
    
    if(self.size >= self.capacity)
    {
        NSLog(@"Thread[%@] put wait %@",[NSThread currentThread],value);
        pthread_cond_wait(&putCondition, &putMutex);
    }
    
    NSLog(@"Thread[%@] put start %@",[NSThread currentThread],value);
    
    pthread_mutex_lock(&syncMutex);
    
    [self.queue insertObject:value atIndex:0];
    
    pthread_mutex_unlock(&syncMutex);
    
    NSLog(@"Thread[%@] put end %@",[NSThread currentThread],value);
    
    pthread_cond_signal(&takeCondition);
    
    pthread_mutex_unlock(&putMutex);
    
    NSLog(@"Thread[%@] count %ld",[NSThread currentThread],self.size);

}



- (id) take
{
    id value = nil;
    
    pthread_mutex_lock(&takeMutex);
    
    if(self.size <= 0)
    {
        NSLog(@"Thread[%@] take wait",[NSThread currentThread]);
        pthread_cond_wait(&takeCondition, &takeMutex);
    }
  
    NSLog(@"Thread[%@] take start",[NSThread currentThread]);
    
    pthread_mutex_lock(&syncMutex);
    
    value = [self.queue lastObject];
    [self.queue removeLastObject];
    
    pthread_mutex_unlock(&syncMutex);
    
    NSLog(@"Thread[%@] take %@ end",[NSThread currentThread],value);
    
    pthread_cond_signal(&putCondition);
    
    NSLog(@"Thread[%@] count %ld",[NSThread currentThread],self.size);
    
    pthread_mutex_unlock(&takeMutex);
    
    return value;
}


- (void) dealloc
{
    pthread_mutex_destroy(&syncMutex);
    
    pthread_cond_destroy(&putCondition);
    pthread_mutex_destroy(&putMutex);
    
    pthread_cond_destroy(&takeCondition);
    pthread_mutex_destroy(&takeMutex);
}




@end
