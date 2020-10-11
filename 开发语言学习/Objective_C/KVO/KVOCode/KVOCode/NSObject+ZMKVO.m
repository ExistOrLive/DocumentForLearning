//
//  NSObject+ZMKVO.m
//  KVOCode
//
//  Created by panzhengwei on 2018/12/24.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "NSObject+ZMKVO.h"
#import <objc/runtime.h>
#import <string.h>

@implementation NSObject (ZMKVO)

- (void) ZM_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
    const char * oldClassName = object_getClassName(self);
    char newClassName[20] = "ZMKVO_";
    strcat(newClassName, oldClassName);
    
    /**
     *  创建一个新的类及其元类
     *
     **/
    Class newClass = objc_allocateClassPair(object_getClass(self), newClassName, 0);

    /**
     *
     * 注册由objc_allocateClassPair创建的类，只有注册后才可以使用
     **/
    objc_registerClassPair(newClass);

    /**
     *
     * 为类添加方法，如果方法名与父类方法名相同，则为重写
     **/
    class_addMethod(newClass,@selector(setValue1:),(IMP)setValue1, "");
    
    
    /**
     *
     * 修改某个实例的isa指针，即类对象
     **/
    object_setClass(self, newClass);
}


- (void) ZM_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context
{
    
}

- (void) ZM_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
    
}


void setValue1(id self,SEL _cmd,id value)
{
    NSLog(@"%@",value);
}




@end
