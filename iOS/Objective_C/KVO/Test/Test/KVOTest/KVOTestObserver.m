
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
    
     [_test1 setValue1:@"2"];
   
    [_test1 addObserver:self forKeyPath:@"value1" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    
    [_test1 setValue1:@"1"];
    

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",change);
}


- (void) testArray
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
//    [array mutableArrayValueForKeyPath:@"arr"];
//
//    [array addObserver:self forKeyPath:@"count" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];
//
//    [array addObject:@"a"];
    
    Class a1 = [array class];
    NSLog(@"%@",a1);
}

@end
