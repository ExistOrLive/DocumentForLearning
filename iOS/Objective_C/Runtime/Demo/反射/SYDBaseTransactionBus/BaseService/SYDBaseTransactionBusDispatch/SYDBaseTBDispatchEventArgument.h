//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYDBaseTBDispatchEventArgumentForSender;
@class SYDBaseTBDispatchEventArgumentForReceiver;


typedef  NS_ENUM(NSUInteger, EventTypeForReceiver)
{
    EventTypeForReceiver_SYNC,
    EventTypeForReceiver_ASYNC,
    EventTypeForReceiver_DirectInvoke
};

/**
 分发事件类，参数传递用，带有所有信息
 */
@interface SYDBaseTBDispatchEventArgument : NSObject


/**
 发送者信息
 */
@property(strong, nonatomic) SYDBaseTBDispatchEventArgumentForSender * aSenderArgument;

/**
 接受者信息
 */
@property(strong, nonatomic) SYDBaseTBDispatchEventArgumentForReceiver * aReceiveArgument;


@property(assign, nonatomic) EventTypeForReceiver aEventTypeForReceiver;

/**
 真实接口参数
 */
@property(strong, nonatomic) id aMethodArgumentData;
@end
