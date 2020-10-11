//
//  SYDBaseService.h
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYDBaseTBDispatchHeader.h"

/**
 具体实现类要实现的入口方法，作为每个业务的总控，入口
 */
@protocol TransactionBusProtocol <NSObject>

- (id) precessTransaction:(SYDBaseTBDispatchEventArgument *) argument;

@end



/**
 用于继承，本身无较多信息，后期用于监控
 */
@interface SYDBaseTransactionBus : NSObject <TransactionBusProtocol>

@end
