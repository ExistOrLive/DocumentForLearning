//
//  KVOTest.h
//  Test
//
//  Created by panzhengwei on 2018/12/22.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVOTestValue.h"

@interface KVOTest : NSObject
{
    
}

@property(nonatomic,strong) NSString * value1;

@property(nonatomic,strong) NSString * value2;

@property(nonatomic,strong) KVOTestValue * vaule3;

@property(nonatomic,strong) NSMutableArray * array;

@property(nonatomic,strong) NSMutableDictionary* dic;



@end
