//
//  SYDBaseService.mm
//  MOA
//
//  Created by apple on 16-5-20.
//  Copyright (c) 2016年 zte. All rights reserved.
//

#import "SYDBaseTransactionBus.h"

@implementation SYDBaseTransactionBus

- (id) precessTransaction:(SYDBaseTBDispatchEventArgument *) argument
{
    NSLog(@"precessTransaction: receive[%@] methodStr[%@] aMethodNum[%ld] sender[%@] operatedId[%@]", argument.aReceiveArgument.receiver, argument.aReceiveArgument.aMethodStr, (unsigned long)argument.aReceiveArgument.aMethodNum, argument.aSenderArgument.sender, argument.aSenderArgument.operatedId);
    
    return @YES;
}

@end
