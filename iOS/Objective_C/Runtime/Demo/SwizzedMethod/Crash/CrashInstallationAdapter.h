//
//  CrashInstallationAdapter.h
//  iCenter
//
//  Created by joey.hzw on 2017/12/5.
//  Copyright © 2017年 MyApp. All rights reserved.
//

#import <KSCrash/KSCrash.h>
#import <KSCrash/KSCrashInstallation.h>

@interface CrashInstallationAdapter : KSCrashInstallation

@property(nonatomic,readwrite,retain) NSURL* url;
//@required
@property(nonatomic,readwrite,retain) NSString* employeeShortId;
@property(nonatomic,readwrite,retain) NSString* employeeName;
@property(nonatomic,readwrite,retain) NSString* loginFrom; //ios
@property(nonatomic,readwrite,retain) NSString* clientVersion;

//@optional
@property(nonatomic,readwrite,retain) NSString* loginIp;
@property(nonatomic,readwrite,retain) NSString* imeiNo;
@property(nonatomic,readwrite,retain) NSString* systemVersion;

+ (instancetype) sharedInstance;
@end
