//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 接受者参数类
 */
@interface SYDBaseTBDispatchEventArgumentForReceiver : NSObject

/**
 接受者类名
 */
@property(strong, nonatomic) NSString * receiver;


/**
 接受者方法名，和 aMethodNum 有重复嫌疑
 */
@property(strong, nonatomic) NSString * aMethodStr;


/**
 接受者方法编号，和 aMethodStr 有重复嫌疑，看每个类怎么使用了。
 */
@property(assign, nonatomic) NSUInteger  aMethodNum;

@end
