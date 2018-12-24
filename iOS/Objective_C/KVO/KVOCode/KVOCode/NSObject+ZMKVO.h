//
//  NSObject+ZMKVO.h
//  KVOCode
//
//  Created by panzhengwei on 2018/12/24.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZMKVO)

- (void) ZM_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

@end
