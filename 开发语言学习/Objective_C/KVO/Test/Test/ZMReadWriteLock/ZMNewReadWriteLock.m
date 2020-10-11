//
//  ZMNewReadWhiteLock.m
//  Test
//
//  Created by panzhengwei on 2019/4/30.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import "ZMNewReadWriteLock.h"
#import <pthread.h>

/**
 *  读写锁的实现
 *  1、 写操作之间互斥
 *  2、 读操作之间不互斥
 *  3、 读操作 与 写操作之间互斥
 *  4、 设置两个信号量 isWrite 和 readCount
 **/

@interface ZMNewReadWriteLock()
{
    pthread_mutex_t readCountMutex;
    pthread_cond_t  readCountCondition;
    
    pthread_mutex_t writeMutex;
    pthread_cond_t writeCondition;
    
    int readCount;
    BOOL isWrite;
    
}

@end


@implementation ZMNewReadWriteLock

- (instancetype) init
{
    if(self = [super init])
    {
        pthread_mutex_init(&readCountMutex,NULL);
        pthread_mutex_init(&writeMutex,NULL);
        
        pthread_cond_init(&readCountCondition, NULL);
        pthread_cond_init(&writeCondition, NULL);
    }
    
    return self;
}

- (void) lockReadLock
{
    pthread_mutex_lock(&writeMutex);
    
    if(isWrite)
    {
        pthread_cond_wait(<#pthread_cond_t *restrict _Nonnull#>, <#pthread_mutex_t *restrict _Nonnull#>)
    }
    
}



- (void) unLockReadLock
{
    
}


- (void) lockWriteLock
{
    
}
- (void) unLockWriteLock
{
    
}



@end
