//
//  ZMNewReadWhiteLock.h
//  Test
//
//  Created by panzhengwei on 2019/4/30.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZMNewReadWriteLock : NSObject

- (void) lockReadLock;
- (void) unLockReadLock;


- (void) lockWriteLock;
- (void) unLockWriteLock;


@end
