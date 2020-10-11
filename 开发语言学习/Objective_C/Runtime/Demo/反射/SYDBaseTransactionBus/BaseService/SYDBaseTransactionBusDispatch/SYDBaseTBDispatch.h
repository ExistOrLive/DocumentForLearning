//
//  SYDDispatchService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYDBaseTBDispatchRegisterTaskData;
@class SYDBaseTBDispatchEventArgument;
@class SYDBaseTBDispatchEventArgumentForSender;
@class SYDBaseTBDispatchEventArgumentForReceiver;

typedef NS_ENUM(NSInteger, MethodType)
{
    MethodType_Class,
    MethodType_Instance,
};

typedef struct
{
    NSUInteger aMethodID;
    MethodType aMethodType;
    char aMethodSignName[256];
    char aClassName[256];
}SYDMethodMapTable;


/**
 分发类
 */
@interface SYDBaseTBDispatch : NSObject

/**
 适配发给分发的方法，只有这一个方法

 @param aDestClassName 目标类名
 @param argument 参数
 @return 返回值，必须是一个类
 */
-(id) sendEventTo:(NSString *) aDestClassName AndArgument:(SYDBaseTBDispatchEventArgument *) argument;


/**
 传递给某个类的某个方法

 @param aDestClassHandler 类地址
 @param aMethodStr 方法字符串
 @param aMethodType 方法类型：类方法，实例方法
 @param aArgumentArray 参数列表
 @return 返回值，ID
 */
+(id) sendEventTo:(id) aDestClassHandler AndMethodStr:(NSString *)aMethodStr AndMethodType:(MethodType)aMethodType AndArgumentArray:(NSArray *)aArgumentArray;

+(instancetype) Instance;

/**
 每个需要分发的类，初始化时调用

 @param aRegisterTaskData 入参
 @return 成功或者失败
 */
-(BOOL) registerTask: (SYDBaseTBDispatchRegisterTaskData *) aRegisterTaskData;

/**
 取消注册，一般无用。配套生成

 @param aClassName 类名
 @return 成功或者失败
 */
-(BOOL) UnRegisterTask: (NSString *) aClassName;

@end
