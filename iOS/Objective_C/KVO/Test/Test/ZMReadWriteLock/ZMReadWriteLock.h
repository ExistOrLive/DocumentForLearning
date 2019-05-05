//
//  ZMReadWriteLock.h
//  iCenter
//
//  Created by panzhengwei on 2018/11/1.
//  Copyright © 2018年 MyApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMReadWriteLock : NSObject

- (NSCondition *) lockReadLock;
- (void) unLockReadLock:(NSCondition *) readLock;


- (void) lockWriteLock;
- (void) unLockWriteLock;


@end
