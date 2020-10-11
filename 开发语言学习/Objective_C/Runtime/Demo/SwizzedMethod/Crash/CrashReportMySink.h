//
//  CrashReportMySink.h
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSCrashReportFilter.h"

@interface CrashReportMySink : NSObject<KSCrashReportFilter>
+ (CrashReportMySink*) sinkWithURL:(NSURL*) url
                            userId:(NSString*) userId
                          userName:(NSString*) userName
                         clientVer:(NSString*) clientVer;


- (id <KSCrashReportFilter>) defaultCrashReportFilterSet;
@end
