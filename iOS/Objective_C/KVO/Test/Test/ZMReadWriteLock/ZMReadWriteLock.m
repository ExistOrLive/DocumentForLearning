
//
//  ZMReadWriteLock.m
//  iCenter
//
//  Created by zhumeng on 2018/11/1.
//  Copyright © 2018年 MyApp. All rights reserved.
//

/**
 * 读写锁的设计
 * 1、 写操作互斥，因此写操作之间需要一个互斥锁 writeLock
 * 2、 读操作之间不需要互斥， 因此读操作之间不需要互斥锁
 * 3、 读的时候不可以写，写的时候不可以读 ， 需要信号量 readCount（当前读操作的个数） isWrite（当前时候正在写）
 * 4、 实现信号量通信需要条件锁NSCondition，所有没有读操作都有一个条件锁
 * 5、 修改信号量是互斥的
 *
 *
 *。为了避免死锁，读操作先设置readCount信号量，再判断isWrite信号量; 写操作先
 **/


#import "ZMReadWriteLock.h"

#define ReadLockArraySyncLock @"ReadLockArraySyncLock"

@interface ZMReadWriteLock()

@property(nonatomic, strong) NSCondition * writeLock;

@property(nonatomic, strong) NSMutableArray * readLocks;


@property(nonatomic,assign) int readCount;

@property(nonatomic,assign) BOOL isWrite;

@end

@implementation ZMReadWriteLock

- (instancetype) init
{
    if(self = [super init])
    {
        _writeLock = [[NSCondition alloc] init];
        _readLocks = [[NSMutableArray alloc] init];
        
        _readCount = 0;
        _isWrite = 0;
    }
    
    return self;
}

- (NSCondition *) lockReadLock
{
    NSCondition * readLock = [[NSCondition alloc] init];
    
    [readLock lock];
    
    /**
     *  加了读锁后，首先设置信号量 readCount
     *  信号量的修改需要互斥，通过@synchronied实现
     *  先设置信号量readCount，再判断信号量isWrite，而写锁先判断信号量readCount 再设置信号量isWrite，可以避免死锁
     *  且这样读优先级更高
     **/
    @synchronized(ReadLockArraySyncLock)
    {
        self.readCount ++;
        [self.readLocks addObject:readLock];
    }
    
    
    if(self.isWrite)
    {
        [readLock wait];
    }
    
  
    return readLock;
}

- (void) unLockReadLock:(NSCondition *) readLock
{
    @synchronized(ReadLockArraySyncLock)
    {
         self.readCount --;
        [self.readLocks removeObject:readLock];
    }
    
    if(self.readCount == 0)
    {
        [self.writeLock broadcast];
    }
    
    [readLock unlock];
}


- (void) lockWriteLock
{
    [self.writeLock lock];
    
    if(self.readCount > 0)
    {
        [self.writeLock wait];
    }
    
    @synchronized(ReadLockArraySyncLock)
    {
        self.isWrite = YES;
    }
}


- (void) unLockWriteLock
{
    @synchronized(ReadLockArraySyncLock)
    {
        self.isWrite = NO;
    }
    
    for(NSCondition * condition in self.readLocks)
    {
        [condition signal];
    }

    [self.writeLock unlock];
}





@end
