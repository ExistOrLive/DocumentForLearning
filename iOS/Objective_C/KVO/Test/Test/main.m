//
//  main.m
//  Test
//
//  Created by panzhengwei on 2018/10/31.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVOTest.h"
#import "KVOTestObserver.h"



int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        KVOTestObserver * observer = [[KVOTestObserver alloc] init];
        
        [observer testArray];
        
        [[NSRunLoop mainRunLoop] run];
        
    }
    return 0;
}
