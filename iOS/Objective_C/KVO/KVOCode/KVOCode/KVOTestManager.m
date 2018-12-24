//
//  KVOTestManager.m
//  KVOCode
//
//  Created by panzhengwei on 2018/12/24.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "KVOTestManager.h"
#import "KVOTest.h"
#import "NSObject+ZMKVO.h"

@implementation KVOTestManager

- (void) test
{
    KVOTest * test = [[KVOTest alloc] init];
    
    [test ZM_addObserver:self forKeyPath:@"value1" options:NSKeyValueObservingOptionInitial context:nil];
    
    [test setValue1:@"fafafa"];
}

@end
