//
//  CrashReportMySink.m
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import "CrashReportMySink.h"
#import "KSReachabilityKSCrash.h"
#import "KSHTTPMultipartPostBody.h"
#import "KSJSONCodecObjC.h"
#import "NSData+GZip.h"
#import "KSHTTPRequestSender.h"
#import "NSError+SimpleConstructor.h"
#import "KSSystemCapabilities.h"
#import "KSCrashReportFilterBasic.h"
#import "KSCrashReportFilterAppleFmt.h"
#import "CommonUtilities.h"

@interface CrashReportMySink()
@property(nonatomic,readwrite,retain) NSURL* url;
@property(nonatomic,readwrite,retain) NSString* userId;
@property(nonatomic,readwrite,retain) NSString* userName;

@property(nonatomic,readwrite,retain) NSString* clientVersion;
@property(nonatomic,readwrite,retain) KSReachableOperationKSCrash* reachableOperation;
@end


@implementation CrashReportMySink
+ (CrashReportMySink*) sinkWithURL:(NSURL*) url
                            userId:(NSString*) userId
                          userName:(NSString*) userName
                         clientVer:(NSString*) clientVer {
    CrashReportMySink *sink = [[CrashReportMySink alloc] init];
    sink.url = url;
    sink.userId = userId;
    sink.userName = userName;
    sink.clientVersion = clientVer;
    
    return sink;
}

- (id <KSCrashReportFilter>) defaultCrashReportFilterSet
{
    return [KSCrashReportFilterPipeline filterWithFilters:
            [KSCrashReportFilterAppleFmt filterWithReportStyle:KSAppleReportStyleSymbolicated],
            self,
            nil];
}

- (void) filterReports:(NSArray*) reports
          onCompletion:(KSCrashReportFilterCompletion) onCompletion
{
    NSMutableString *allReports = [NSMutableString string];
    int i = 0;
    for(NSString* report in reports)
    {
        //printf("Report %d:\n%s\n", ++i, report.UTF8String);
        [allReports appendFormat:@"Report %d:\n%s\n", ++i, report.UTF8String];
    }

    
    NSError* error = nil;
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:15];
    KSHTTPMultipartPostBody* body = [KSHTTPMultipartPostBody body];
//    NSData* jsonData = [KSJSONCodec encode:reports
//                                   options:KSJSONEncodeOptionSorted
//                                     error:&error];
    
    NSData* jsonData = [allReports dataUsingEncoding:NSUTF8StringEncoding];
    if(jsonData == nil)
    {
        kscrash_callCompletion(onCompletion, reports, NO, error);
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *reportName = [NSString stringWithFormat:@"crash_%@.txt",dateStr];
    [body appendData:jsonData
                name:@"multipartFile"
         contentType:@"multipart/form-data"
            filename:reportName];
    
    [body appendUTF8String:self.userId name:@"employeeShortId" contentType:nil filename:nil];
    [body appendUTF8String:self.userName name:@"employeeName" contentType:nil filename:nil];
    [body appendUTF8String:@"ios" name:@"loginFrom" contentType:nil filename:nil];
    [body appendUTF8String:[CommonUtilities getVersionInfo] name:@"clientVersion" contentType:nil filename:nil];
    [body appendUTF8String:[CommonUtilities getCurrentDeviceModel] name:@"phoneMode" contentType:nil filename:nil];
    [body appendUTF8String:[CommonUtilities getIOSVersion] name:@"systemVersion" contentType:nil filename:nil];
    [body appendUTF8String:[CommonUtilities getIpAddresses] name:@"loginIp" contentType:nil filename:nil];
    
    // POST http request
    // Content-Type: multipart/form-data; boundary=xxx
    // Content-Encoding: gzip
    request.HTTPMethod = @"POST";
    request.HTTPBody = [body data];//[[body data] gzippedWithCompressionLevel:-1 error:nil];
    [request setValue:body.contentType forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setValue:@"KSCrashReporter" forHTTPHeaderField:@"User-Agent"];
    
    self.reachableOperation = [KSReachableOperationKSCrash operationWithHost:[self.url host]
                                                                   allowWWAN:YES
                                                                       block:^
                               {
                                   [[KSHTTPRequestSender sender] sendRequest:request
                                                                   onSuccess:^(__unused NSHTTPURLResponse* response, __unused NSData* data)
                                    {
                                        NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                        NSLog(@"ret is back %@",ret);
                                        kscrash_callCompletion(onCompletion, reports, YES, nil);
                                    } onFailure:^(NSHTTPURLResponse* response, NSData* data)
                                    {
                                        NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                        kscrash_callCompletion(onCompletion, reports, NO,
                                                               [NSError errorWithDomain:[[self class] description]
                                                                                   code:response.statusCode
                                                                            description:text]);
                                    } onError:^(NSError* error2)
                                    {
                                        kscrash_callCompletion(onCompletion, reports, NO, error2);
                                    }];
                               }];
}

@end
