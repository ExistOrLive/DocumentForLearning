//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYDBaseTBDispatchRegisterTaskData;

/**
 运行时数据，不对外开放
 */
@interface SYDBaseTBDispatchRunData : NSObject

/**
 注册数据
 */
@property(strong, nonatomic) SYDBaseTBDispatchRegisterTaskData *aRegisterTaskData;

@end
