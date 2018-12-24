//
//  KVOTest.m
//  Test
//
//  Created by panzhengwei on 2018/12/22.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "KVOTest.h"

@implementation KVOTest

- (instancetype) init
{
    if(self = [super init])
    {
        _value1 = @"dasda";
        _array = [[NSMutableArray alloc] init];
        _dic = [[NSMutableDictionary alloc] init];
    }
    
    return self;

}


- (void) printClassName
{
   
}


@end
