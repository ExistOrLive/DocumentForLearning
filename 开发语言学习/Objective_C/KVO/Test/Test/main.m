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

void test(int a,int b,...)
{
    va_list list;                // 定义一个 va_list类型, va_list类型实际上是一个指向形式参数的指针
    
    va_start(list,b);            // 初始化list指针，指向参数b后一个参数
    
    int c = va_arg(list,int);    // 取出list当前指向的参数，并将list指向下一个参数
    
    printf("%d",c);
    
    va_end(list);                // 将list指针置为 0
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        test(1,2,3);
        
    }
    return 0;
}
