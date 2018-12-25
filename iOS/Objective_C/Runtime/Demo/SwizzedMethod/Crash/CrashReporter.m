//
//  CrashReporter.m
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import "CrashReporter.h"
#import <KSCrash/KSCrash.h>
#import "CrashInstallationAdapter.h"
#import "PersonalService.h"
#import "IniUtilities.h"
// MOAPG
#import "LogInfoManager+Trace.h"
#import "MD5.h"
#import "NSString+IW.h"
#import <mach-o/dyld.h>

#define kUploadCrashLog         @"crashLog/uploadCrashLog"


@interface CrashReporter()
@property (nonatomic, strong) CrashInstallationAdapter *myInstallation;
@end

@implementation CrashReporter
+(instancetype)sharedInstance {
    static CrashReporter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[CrashReporter alloc] init];
        }
    });
    return instance;
}

+(NSString*)crashlogUrl {
    return [NSString stringWithFormat:@"%@%@",A2N(gConfigUI.CrashLogUrl),kUploadCrashLog];
}

-(void)setup {
    [KSCrash sharedInstance].deleteBehaviorAfterSendAll = KSCDeleteOnSucess;
    
    CrashInstallationAdapter* installation = [CrashInstallationAdapter sharedInstance];
    installation.url = [NSURL URLWithString:[[self class] crashlogUrl]];
    DDLogInfo(@"crashLogUrl:%@",installation.url);
    installation.employeeShortId = [PersonalService Instance].userID ?: @"";
    installation.employeeName = [PersonalService Instance].imPersonalInfo.name ?: @"";
    
    installation.clientVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    //[installation setReportStyle:KSCrashEmailReportStyleApple useDefaultFilenameFormat:YES];
    [installation install];
    
    self.myInstallation = installation;
    
    [self upload];
}

-(void)upload {
    [self.myInstallation sendAllReportsWithCompletion:^(NSArray *filteredReports, BOOL completed, NSError *error)
    {
        [PersonalService addRecordPoint:@"Exception_collapse" tag:@"异常-应用闪退" WithUMSAgentType:Other];
        // Stuff to do when report sending is complete
        NSLog(@"============= crash report uploaded");
        
        //体验数据上报 MOAPG
        NSString *callStackSymbols = [filteredReports lastObject];
        if (callStackSymbols && ![callStackSymbols isEqualToString:@""]) {
            NSArray *array = [callStackSymbols componentsSeparatedByString:@"\n\n"];
            NSString *crashCause = @"";
            NSString *crashStackInfo = @"";
            for (NSString *stackStr in array) {
                if ([stackStr containsString:@"Application Specific Information:"]) {
                    crashCause = [[stackStr componentsSeparatedByString:@"\n"] lastObject];
                }
                if ([stackStr containsString:@"Crashed"]) {
                    crashStackInfo = [crashStackInfo stringByAppendingString:[NSString stringWithFormat:@"\n%@",stackStr]];
                }
            }
            //获取内存地址的偏移量slide
            for (uint32_t i=0; i < _dyld_image_count(); i++) {
                if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
                    long slide = _dyld_get_image_vmaddr_slide(i);
                    crashStackInfo = [NSString stringWithFormat:@"%@\nSlide Address(16 Hexadecimal):%@",crashStackInfo,[NSString getHexByDecimal:slide]];
                    break;
                }
            }
            NSString *md5Str = [MD5 md5Lowercase:crashStackInfo];
            NSData *callStackSymbolsData = [crashStackInfo dataUsingEncoding:NSUTF8StringEncoding];
            crashStackInfo = [callStackSymbolsData base64EncodedStringWithOptions:0];
            
            USADTraceDataHead * traceDataHead = [[USADTraceDataHead alloc] initWithTraceType:USAD_TraceType_Crash streamingNO:[SYDStringUtilities genereateSerialNumber] curStep:USAD_TraceStep_init operateTime:[SYDStringUtilities getTimeZoneStringYYYYMMddHHmmssSSS] result:0 end:YES curSubStep:USAD_TraceStep_init];
            USADTraceModel_appCrash * traceModel = [[USADTraceModel_appCrash alloc] initWithCrashCause:crashCause?crashCause:@"" crashStackInfoMd5:md5Str crashStackInfo:crashStackInfo];
            [[SoftDAOCX Instance] trace:NSStringFromClass([self class]) head:traceDataHead model:traceModel];
        }
    }];
}
@end
