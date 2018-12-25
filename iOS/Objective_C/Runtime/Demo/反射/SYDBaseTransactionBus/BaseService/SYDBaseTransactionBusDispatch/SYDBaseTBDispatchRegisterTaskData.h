//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 分发所需要的注册信息类
 */
@interface SYDBaseTBDispatchRegisterTaskData : NSObject

/**
 注册的类名
 */
@property(strong, nonatomic) NSString * aClassName;


/**
 注册的类的句柄
 */
@property(weak) id aRegisterHandle;

@end
