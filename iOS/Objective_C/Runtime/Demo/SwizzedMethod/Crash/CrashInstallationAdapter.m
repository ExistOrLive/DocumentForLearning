//
//  CrashInstallationAdapter.m
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import "CrashInstallationAdapter.h"
#import "CrashReportMySink.h"
#import "KSCrashReportFilterBasic.h"
#import "KSCrashInstallation+Private.h"

@implementation CrashInstallationAdapter
+ (instancetype) sharedInstance
{
    static CrashInstallationAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CrashInstallationAdapter alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    return [super initWithRequiredProperties:[NSArray arrayWithObjects: @"url", nil]];
}

- (id<KSCrashReportFilter>) sink
{
    CrashReportMySink* sink = [CrashReportMySink sinkWithURL:self.url userId:self.employeeShortId userName:self.employeeName clientVer:self.clientVersion];
    return [KSCrashReportFilterPipeline filterWithFilters:[sink defaultCrashReportFilterSet], nil];
}
@end
