//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 发送者参数类
 */
@interface SYDBaseTBDispatchEventArgumentForSender : NSObject

/**
 发送者, 也即哪个类，类名
 */
@property(strong, nonatomic) NSString * sender;

/**
 回调句柄, 处理完毕，需要回调以返回结果， 回掉的方法是委托方法，固定的， 异步方法时使用
 */
@property(weak, nonatomic) id callbackhandler;

/**
 操作ID， 用于请求和响应在调用者处做关联，业务原样返回
 */
@property(strong, nonatomic) NSString * operatedId;

/**
 用于请求和响应在调用者处做关联，业务原样返回， 暂时无用， str 类型
 */
@property(strong, nonatomic) NSString * reserveStr;

//! 用于请求和响应在调用者处做关联，业务原样返回

/**
 用于请求和响应在调用者处做关联，业务原样返回， 暂时无用， int类型
 */
@property(assign, nonatomic) NSInteger reserveInt;

@end
