
//
//  KVOTestObserver.m
//  Test
//
//  Created by panzhengwei on 2018/12/22.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "KVOTestObserver.h"
#import "KVOTest.h"
#import "KVOTestValue.h"
#import <objc/runtime.h>

@interface KVOTestObserver()

@property(nonatomic,strong) KVOTest * test1;

@end

@implementation KVOTestObserver



- (void) test
{
    self.test1 = [[KVOTest alloc] init];
    
    Method method1 = class_getInstanceMethod(object_getClass(self.test1), @selector(setValue1:));
    IMP imp1 = method_getImplementation(method1);
    Class class1 = object_getClass(self.test1);
   
    [self.test1 addObserver:self forKeyPath:@"value1" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior context:nil];

    
    Method method2 = class_getInstanceMethod(object_getClass(self.test1), @selector(setValue1:));
    IMP imp2 = method_getImplementation(method2);
    Class class2 = object_getClass(self.test1);
    
    [self.test1 setValue1:@"1"];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",change);
}


- (void) testArray
{
   
//    [array addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];

    self.test1 = [[KVOTest alloc] init];

    [self.test1 addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];

    NSMutableArray * tmpArray = [self.test1 mutableArrayValueForKey:@"array"];

    [tmpArray addObject:@"b"];
    
    [tmpArray addObject:@"a"];
    
    [tmpArray addObject:@"c"];

}

@end
