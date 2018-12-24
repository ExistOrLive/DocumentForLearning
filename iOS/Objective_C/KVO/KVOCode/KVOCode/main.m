//
//  main.m
//  KVOCode
//
//  Created by zhumeng on 2018/12/24.
//  Copyright © 2018年 ZTE. All rights reserved.
//


/**
 * 通过运行时实现KVO的效果
 *
 **/
#import <Foundation/Foundation.h>
#import "KVOTestManager.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
     
        [[[KVOTestManager alloc] init] test];
    }
    return 0;
}
