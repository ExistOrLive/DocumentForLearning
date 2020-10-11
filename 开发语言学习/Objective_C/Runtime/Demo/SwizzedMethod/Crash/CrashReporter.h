//
//  CrashReporter.h
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashReporter : NSObject
+(instancetype)sharedInstance;

-(void)setup;
-(void)upload;
@end
