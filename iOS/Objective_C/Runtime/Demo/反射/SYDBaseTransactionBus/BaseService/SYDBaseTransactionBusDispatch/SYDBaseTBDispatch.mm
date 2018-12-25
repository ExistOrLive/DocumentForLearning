//
//  SYDDispatchService.mm
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import "SYDBaseTBDispatch.h"

#import "SYDBaseTBDispatchRunData.h"

#import "SYDBaseTBDispatchRegisterTaskData.h"
#import "SYDBaseTBDispatchEventArgument.h"
#import "SYDBaseTBDispatchEventArgumentForSender.h"
#import "SYDBaseTBDispatchEventArgumentForReceiver.h"

#import <objc/runtime.h>
//#import <objc/message.h>

@class SYDBaseTBDispatchRegisterTaskData;
@class SYDBaseTBDispatchEventArgument;
@class SYDBaseTBDispatchEventArgumentForSender;
@class SYDBaseTBDispatchEventArgumentForReceiver;

static NSString * aClassDefaultEventProcessMethod = @"precessTransaction:";

@implementation SYDBaseTBDispatch
{
    //k-v: aClassName -- SYDTaskRunData
    NSMutableDictionary * aDispatchDic;
}


+ (SYDBaseTBDispatch*) Instance
{
    static SYDBaseTBDispatch* s_WDispatchService = nil;
    
    if (s_WDispatchService == nil)
    {
        s_WDispatchService = [[SYDBaseTBDispatch alloc] init];
    }
    
    return s_WDispatchService;
}

- (SYDBaseTBDispatch*) init
{
//    LOG_DEBUGGING("");
    
    self = [super init];
    
    if (self != nil)
    {
        aDispatchDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(BOOL) checkRegisterTaskDataValid: (SYDBaseTBDispatchRegisterTaskData *) aRegisterTaskData
{
    if (0 == [aRegisterTaskData.aClassName length] || !aRegisterTaskData.aRegisterHandle)
    {
        NSLog(@"SYDDispatchService registerTask, failed: para error");
        return NO;
    }
    
    if ([aDispatchDic objectForKey: aRegisterTaskData.aClassName])
    {
        NSLog(@"SYDDispatchService registerTask, failed: had register");
        return NO;
    }
    
    return YES;
}

-(BOOL) registerTask: (SYDBaseTBDispatchRegisterTaskData *) aRegisterTaskData
{
    NSLog(@"registerTask, Info: aRegisterTaskData: aClassName[%@] aRegisterHandle[%@]", aRegisterTaskData.aClassName, aRegisterTaskData.aRegisterHandle);
    
    if ([self checkRegisterTaskDataValid: aRegisterTaskData])
    {
        SYDBaseTBDispatchRunData *aTaskRunData = [[SYDBaseTBDispatchRunData alloc] init];
        aTaskRunData.aRegisterTaskData = [[SYDBaseTBDispatchRegisterTaskData alloc] init];
        
        aTaskRunData.aRegisterTaskData.aRegisterHandle = aRegisterTaskData.aRegisterHandle;
        aTaskRunData.aRegisterTaskData.aClassName = aRegisterTaskData.aClassName;
        
        [aDispatchDic setObject:aTaskRunData forKey:aRegisterTaskData.aClassName];
        
        NSLog(@"registerTask Success");
        
        return YES;
    }
    else
    {
        NSLog(@"SYDDispatchService registerTask, failed");
        return NO;
    }
}

-(BOOL) UnRegisterTask: (NSString *) aClassName
{
//    LOG_DEBUGGING("UnRegisterTask, Info: aRegisterTaskData[%s]", [[aRegisterTaskData description] UTF8String]);
    
    [aDispatchDic removeObjectForKey:aClassName];
    
    return YES;
}

//返回类型，如果是 NSNUMBER类型，则说明执行成功  如果是其他返回值，则可能是静态方法返回的
-(id) sendEventTo:(NSString *) aDestClassName AndArgument:(SYDBaseTBDispatchEventArgument *) argument
{
    NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@], aEventTypeForReceiver[%ld]", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender, (unsigned long)argument.aEventTypeForReceiver);
    
    if (aDestClassName.length <= 0)
    {
        return @NO;
    }
    
    SYDBaseTBDispatchRunData *aTaskRunData = [aDispatchDic objectForKey: aDestClassName];
    
    if (aTaskRunData)
    {
        id aRegisterHandler = aTaskRunData.aRegisterTaskData.aRegisterHandle;
        
        return [[self class] sendEventTo:aRegisterHandler AndMethodStr:aClassDefaultEventProcessMethod AndMethodType:MethodType_Instance AndArgumentArray:[NSArray arrayWithObjects:argument, nil]];
    }
    else
    {
        NSLog(@"ERROR: sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@]: unknow destClass", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender);
        
        return @NO;
    }
}

////返回类型，如果是 NSNUMBER类型，则说明执行成功  如果是其他返回值，则可能是静态方法返回的
//-(id) sendEventTo:(NSString *) aDestClassName AndArgument:(SYDBaseTBDispatchEventArgument *) argument
//{
//    NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@], aEventTypeForReceiver[%ld]", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender, (unsigned long)argument.aEventTypeForReceiver);
//    
//    if (aDestClassName.length <= 0)
//    {
//        return @NO;
//    }
//    
//    SYDBaseTBDispatchRunData *aTaskRunData = [aDispatchDic objectForKey: aDestClassName];
//    
////    NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld]:::111111", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum);
//    
//    if (aTaskRunData)
//    {
//        id aRegisterHandler = aTaskRunData.aRegisterTaskData.aRegisterHandle;
//
//        //动态实例方法
//        SEL myMethod = NSSelectorFromString(aClassDefaultEventProcessMethod);
//        
//////        NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld]:::22222", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum);
////        
////        if ([aRegisterHandler respondsToSelector:myMethod])
////        {
//////            ((void(*)(id,SEL,id))objc_msgSend)(aRegisterHandler, myMethod, argument);
////            id returnValue = ((id(*)(id,SEL,id))objc_msgSend)(aRegisterHandler, myMethod, argument);
////            
//////            NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] returnValue[%@]:::33333", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, returnValue);
////            
////            return returnValue;
////        }
////        else
////        {
////            NSLog(@"ERROR: sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@] can not find precessServiceEvent method", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender);
////            return @NO;
////        }
//        
//        NSMethodSignature *sign = [[aRegisterHandler class] instanceMethodSignatureForSelector:myMethod];
//        
//        if (sign == nil)
//        {
//            NSLog(@"ERROR: sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@] can not find precessServiceEvent method", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender);
//            return @NO;
//        }
//        
////        NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld]:::33333", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum);
//        
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
//        
//        [invocation setTarget:aRegisterHandler];
//        [invocation setSelector:myMethod];
//        [invocation setArgument:&argument atIndex:2];
//        
//        [invocation invoke];
//        
////        NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld]:::44444", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum);
//        
//        __autoreleasing id returnValue = nil;
//        [invocation getReturnValue:&returnValue];
//        
////        NSLog(@"sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld]:::55555", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum);
//        
//        return returnValue;
//    }
//    else
//    {
//        NSLog(@"ERROR: sendEventTo:aDestClassName[%@] methodStr[%@] aMethodNum[%ld] sender[%@]: unknow destClass", aDestClassName, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender);
//        
//        return @NO;
//    }
//}



+(NSMethodSignature *) getMethodSignature:(SEL) myMethodSEL andClass:(Class) aDestClass andMethodTYpe:(MethodType) aMethodType
{
    if (MethodType_Class == aMethodType)
    {
        return [aDestClass methodSignatureForSelector:myMethodSEL];
    }
    else
    {
        return [aDestClass instanceMethodSignatureForSelector:myMethodSEL];
    }
}

+(Method) getMethod:(SEL) myMethodSEL andClass:(Class) aDestClass andMethodTYpe:(MethodType) aMethodType
{
    //静态类方法 //动态类方法
    if (MethodType_Class == aMethodType)
    {
        return class_getClassMethod(aDestClass, myMethodSEL);
    }
    else
    {
        return class_getInstanceMethod(aDestClass, myMethodSEL);
    }
}

+(BOOL) checkArgumentConsistent:(unsigned int) aArgumentCount andGivenCount:(NSUInteger) aGivenArgumentCount
{
    if (aArgumentCount - 2 != aGivenArgumentCount)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

+(id) dealReturnValueForMethod:(Method) aMethod andNSInvocation:(NSInvocation *) aNSInvocation
{
    char pReturnType[100] = {0};
    size_t ReturnTypeLen = 100;
    
    //type @encode
    method_getReturnType(aMethod, pReturnType, ReturnTypeLen);
    
    __autoreleasing id returnValue = nil;
    BOOL result = YES;

    char c = pReturnType[0];
    
    switch (c)
    {
        case _C_ID: //'@':
        {
            //An Object
            [aNSInvocation getReturnValue:&returnValue];
            break;
        }
        case _C_CLASS: //'#':
        {
            //A class object(Class)
            NSLog(@"dealReturnValueForMethod::not support 'class object'");
            result = NO;
            break;
        }
        case _C_SEL://':':
        {
            //A method selector(SEL)
            NSLog(@"dealReturnValueForMethod::not support 'method selector'");
            result = NO;
            break;
        }
        case _C_CHR://'c':
        {
            //A char
            char aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithChar:aReturnArgument];
            break;
        }
        case _C_UCHR://'C':
        {
            //A unsgined char
            unsigned char aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithUnsignedChar:aReturnArgument];
            break;
        }
        case _C_SHT://'s':
        {
            //A short
            short aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithShort:aReturnArgument];
            break;
        }
        case _C_USHT://'S':
        {
            //A unsgined short
            unsigned short aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithUnsignedShort:aReturnArgument];
            break;
        }
        case _C_INT://'i':
        {
            //An int
            int aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithInt:aReturnArgument];
            break;
        }
        case _C_UINT://'I':
        {
            //An unsgined int
            unsigned int aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithUnsignedInt:aReturnArgument];
            break;
        }
        case _C_LNG://'l':
        {
            //A long
            long aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithLong:aReturnArgument];
            break;
        }
        case _C_ULNG://'L':
        {
            //A unsgined long
            unsigned long aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithUnsignedLong:aReturnArgument];
            break;
        }
        case _C_LNG_LNG://'q':
        {
            //A long long
            long long aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithLongLong:aReturnArgument];
            break;
        }
        case _C_ULNG_LNG://'Q':
        {
            //A unsgined long long
            unsigned long long aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithUnsignedLongLong:aReturnArgument];
            break;
        }
        case _C_FLT://'f':
        {
            //A float
            float aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithFloat:aReturnArgument];
            break;
        }
        case _C_DBL://'d':
        {
            //A double
            double aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithDouble:aReturnArgument];
            break;
        }
        case _C_BFLD://'b':
        {
            //A bit field of num bits
            NSLog(@"dealReturnValueForMethod::not support 'bit field of num bits'");
            result = NO;
            break;
        }
        case _C_BOOL://'B':
        {
            //A C++ bool or aC99 _Bool
            bool aReturnArgument = 0;
            [aNSInvocation getReturnValue:&aReturnArgument];
            
            returnValue = [NSNumber numberWithBool:aReturnArgument];
            break;
        }
        case _C_VOID://'v':
        {
            //A void
            NSLog(@"dealReturnValueForMethod::not support 'void'");
            result = NO;
            break;
        }
        case _C_UNDEF://'?':
        {
            //A unknow type
            NSLog(@"dealReturnValueForMethod::not support 'unknow type'");
            result = NO;
            break;
        }
        case _C_PTR://'^':
        {
            //A pointer to type
            NSLog(@"dealReturnValueForMethod::not support 'pointer to type'");
            result = NO;
            break;
        }
        case _C_CHARPTR://'*':
        {
            //A character string(char *)
            NSLog(@"dealReturnValueForMethod::not support 'character string'");
            result = NO;
            break;
        }
        case _C_ATOM://'%':
        {
            //A atom
            NSLog(@"dealReturnValueForMethod::not support 'atom'");
            result = NO;
            break;
        }
        case _C_ARY_B://'[':
        {
            //A array begin
            NSLog(@"dealReturnValueForMethod::not support 'array begin'");
            result = NO;
            break;
        }
        case _C_ARY_E://']':
        {
            //A array end
            NSLog(@"dealReturnValueForMethod::not support 'array end'");
            result = NO;
            break;
        }
        case _C_UNION_B://'(':
        {
            //A union begin
            NSLog(@"dealReturnValueForMethod::not support 'union begin'");
            result = NO;
            break;
        }
        case _C_UNION_E://')':
        {
            //A union end
            NSLog(@"dealReturnValueForMethod::not support 'union end'");
            result = NO;
            break;
        }
        case _C_STRUCT_B://'{':
        {
            //A struct begin
            NSLog(@"dealReturnValueForMethod::not support 'struct begin'");
            result = NO;
            break;
        }
        case _C_STRUCT_E://'}':
        {
            //A struct end
            NSLog(@"dealReturnValueForMethod::not support 'struct end'");
            result = NO;
            break;
        }
        case _C_VECTOR://'!':
        {
            //A vector
            NSLog(@"dealReturnValueForMethod::not support 'vector'");
            result = NO;
            break;
        }
        case _C_CONST://'r':
        {
            //A const
            NSLog(@"dealReturnValueForMethod::not support 'const'");
            result = NO;
            break;
        }
        default:
        {
            result = NO;
            break;
        }
    }
    
    if (result)
    {
        return returnValue;
    }
    else
    {
        return nil;
    }
}


+(BOOL) setNSInvocationArgument:(id)aObjectArgument atIndex:(NSInteger)idx andMethod:(Method) aMethod andNSInvocation:(NSInvocation *) aNSInvocation
{
    char pArgumentType[100] = {0};
    size_t ArgumentTypeLen = 100;
    
    BOOL result = YES;
    
    //type @encode
    method_getArgumentType(aMethod, (unsigned int)idx, pArgumentType, ArgumentTypeLen);
    
    char c = pArgumentType[0];
    
    switch (c)
    {
        case _C_ID: //'@':
        {
            //An Object
            [aNSInvocation setArgument:&aObjectArgument atIndex:idx];
            break;
        }
        case _C_CLASS: //'#':
        {
            //A class object(Class)
            NSLog(@"setNSInvocationArgument::not support 'class object'");
            result = NO;
            break;
        }
        case _C_SEL://':':
        {
            //A method selector(SEL)
            NSLog(@"setNSInvocationArgument::not support 'method selector'");
            result = NO;
            break;
        }
        case _C_CHR://'c':
        {
            //A char
            char aArgument = [aObjectArgument charValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_UCHR://'C':
        {
            //A unsgined char
            unsigned char aArgument = [aObjectArgument unsignedCharValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_SHT://'s':
        {
            //A short
            short aArgument = [aObjectArgument shortValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_USHT://'S':
        {
            //A unsgined short
            unsigned short aArgument = [aObjectArgument unsignedShortValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_INT://'i':
        {
            //An int
            int aArgument = [aObjectArgument intValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_UINT://'I':
        {
            //An unsgined int
            unsigned int aArgument = [aObjectArgument unsignedIntValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_LNG://'l':
        {
            //A long
            long aArgument = [aObjectArgument longValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_ULNG://'L':
        {
            //A unsgined long
            unsigned long aArgument = [aObjectArgument unsignedLongValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_LNG_LNG://'q':
        {
            //A long long
            long long aArgument = [aObjectArgument longLongValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_ULNG_LNG://'Q':
        {
            //A unsgined long long
            unsigned long long aArgument = [aObjectArgument unsignedLongLongValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_FLT://'f':
        {
            //A float
            float aArgument = [aObjectArgument floatValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_DBL://'d':
        {
            //A double
            double aArgument = [aObjectArgument doubleValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_BFLD://'b':
        {
            //A bit field of num bits
            NSLog(@"setNSInvocationArgument::not support 'bit field of num bits'");
            result = NO;
            break;
        }
        case _C_BOOL://'B':
        {
            //A C++ bool or aC99 _Bool
            bool aArgument = [aObjectArgument boolValue];
            [aNSInvocation setArgument:&aArgument atIndex:idx];
            break;
        }
        case _C_VOID://'v':
        {
            //A void
            NSLog(@"setNSInvocationArgument::not support 'void'");
            result = NO;
            break;
        }
        case _C_UNDEF://'?':
        {
            //A unknow type
            NSLog(@"setNSInvocationArgument::not support 'unknow type'");
            result = NO;
            break;
        }
        case _C_PTR://'^':
        {
            //A pointer to type
            NSLog(@"setNSInvocationArgument::not support 'pointer to type'");
            result = NO;
            break;
        }
        case _C_CHARPTR://'*':
        {
            //A character string(char *)
            NSLog(@"setNSInvocationArgument::not support 'character string'");
            result = NO;
            break;
        }
        case _C_ATOM://'%':
        {
            //A atom
            NSLog(@"setNSInvocationArgument::not support 'atom'");
            result = NO;
            break;
        }
        case _C_ARY_B://'[':
        {
            //A array begin
            NSLog(@"setNSInvocationArgument::not support 'array begin'");
            result = NO;
            break;
        }
        case _C_ARY_E://']':
        {
            //A array end
            NSLog(@"setNSInvocationArgument::not support 'array end'");
            result = NO;
            break;
        }
        case _C_UNION_B://'(':
        {
            //A union begin
            NSLog(@"setNSInvocationArgument::not support 'union begin'");
            result = NO;
            break;
        }
        case _C_UNION_E://')':
        {
            //A union end
            NSLog(@"setNSInvocationArgument::not support 'union end'");
            result = NO;
            break;
        }
        case _C_STRUCT_B://'{':
        {
            //A struct begin
            NSLog(@"setNSInvocationArgument::not support 'struct begin'");
            result = NO;
            break;
        }
        case _C_STRUCT_E://'}':
        {
            //A struct end
            NSLog(@"setNSInvocationArgument::not support 'struct end'");
            result = NO;
            break;
        }
        case _C_VECTOR://'!':
        {
            //A vector
            NSLog(@"setNSInvocationArgument::not support 'vector'");
            result = NO;
            break;
        }
        case _C_CONST://'r':
        {
            //A const
            NSLog(@"setNSInvocationArgument::not support 'const'");
            result = NO;
            break;
        }
        default:
        {
            result = NO;
            break;
        }
    }
    
    return result;
}

+(id) sendEventTo:(id) aDestClassHandler AndMethodStr:(NSString *)aMethodStr AndMethodType:(MethodType)aMethodType AndArgumentArray:(NSArray *)aArgumentArray
{
    NSLog(@"INFO::###second###sendEventTo:aDestClassName[%@] methodStr[%@] aMethodType[%ld]", NSStringFromClass([aDestClassHandler class]), aMethodStr, (unsigned long)aMethodType);
    
    if (aDestClassHandler == nil || aMethodStr.length <= 0)
    {
        return @NO;
    }
    
    Class dstClass = [aDestClassHandler classForCoder];
    
    SEL myMethodSEL = NSSelectorFromString(aMethodStr);
    
    NSMethodSignature *myMethodSign = [self getMethodSignature:myMethodSEL andClass:dstClass andMethodTYpe:aMethodType];
    
    if (myMethodSign == nil)
    {
        NSLog(@"ERROR::###second###Sign ERROR##sendEventTo:aDestClassName[%@] methodStr[%@] aMethodType[%ld]#### unknow method", NSStringFromClass([aDestClassHandler class]), aMethodStr, (unsigned long)aMethodType);
        return @NO;
    }
    
    Method myMethod = [self getMethod:myMethodSEL andClass:dstClass andMethodTYpe:aMethodType];
    
    unsigned int aArgumentCount = method_getNumberOfArguments(myMethod);
    NSUInteger aGivenArgumentCount = [aArgumentArray count];
    
    if (![self checkArgumentConsistent:aArgumentCount andGivenCount:aGivenArgumentCount])
    {
        NSLog(@"ERROR::###second###Argument ERROR##sendEventTo:aDestClassName[%@] methodStr[%@] aMethodType[%ld]#### wrong argumentNum[need[%u], but given[%ld]]", NSStringFromClass([aDestClassHandler class]), aMethodStr, (unsigned long)aMethodType, aArgumentCount, (unsigned long)aGivenArgumentCount);
        
        return @NO;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:myMethodSign];
    
    [invocation setSelector:myMethodSEL];            //目标方法指针
    
    if (MethodType_Class == aMethodType)            //设置目标类
    {
        [invocation setTarget:dstClass];
    }
    else
    {
        [invocation setTarget:aDestClassHandler];
    }
    
    if (aArgumentCount > 2)
    {
        for (int i = 0; i < aGivenArgumentCount; i++)
        {
            BOOL result = [self setNSInvocationArgument:[aArgumentArray objectAtIndex:i] atIndex:(i+2) andMethod:myMethod andNSInvocation:invocation];
            
            if (!result)
            {
                NSLog(@"Warn::###second###Some Argument ERROR##sendEventTo:aDestClassName[%@] methodStr[%@] aMethodType[%ld]#### not support some argument: idx[%d]", NSStringFromClass([aDestClassHandler class]), aMethodStr, (unsigned long)aMethodType, i);
            }
        }
    }
    
    [invocation invoke];
    
    return [self dealReturnValueForMethod:myMethod andNSInvocation:invocation];
}
@end

