
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

@interface KVOTestObserver()

@property(nonatomic,strong) KVOTest * test1;

@end

@implementation KVOTestObserver



- (void) test
{
    self.test1 = [[KVOTest alloc] init];
   
    [_test1 addObserver:self forKeyPath:@"value1" options:NSKeyValueObservingOptionPrior context:nil];
    
    [_test1 setValue1:@"1"];
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    dic addObserver:<#(nonnull NSObject *)#> forKeyPath:<#(nonnull NSString *)#> options:<#(NSKeyValueObservingOptions)#> context:<#(nullable void *)#>
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"%@",change);
}


@end
