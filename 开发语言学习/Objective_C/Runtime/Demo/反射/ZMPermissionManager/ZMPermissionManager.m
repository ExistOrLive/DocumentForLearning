//
//  ZMPermissionManager.m
//  iCenter
//
//  Created by zhumeng on 2018/10/23.
//  Copyright © 2018年 MyApp. All rights reserved.
//

#import "ZMPermissionManager.h"

#pragma mark  相册使用权限
#import <Photos/Photos.h>

#pragma mark 摄像头,麦克风使用权限
#import <AVFoundation/AVCaptureDevice.h>

#pragma mark  通讯录使用权限
#import <AddressBook/AddressBook.h>

#ifdef __IPHONE_9_0
#import <Contacts/Contacts.h>
#endif

#pragma mark 定位权限
#import <CoreLocation/CoreLocation.h>

#pragma mark -

@interface ZMPermissionManager()

@property(nonatomic,strong) NSDictionary * configProperty;

@end


@implementation ZMPermissionManager

- (instancetype) init
{
    if(self = [super init])
    {
        self.configProperty =
        @{[NSNumber numberWithInt:ZMPermissionRequestType_PhotoLibrary]:@"requestPhotoLibraryUsagePermissionWithAgreeBlock:withDeniedBlock:",
          [NSNumber numberWithInt:ZMPermissionRequestType_Camera]:@"requestCameraUsagePermissionWithAgreeBlock:withDeniedBlock:",
          [NSNumber numberWithInt:ZMPermissionRequestType_Microphone]:@"requestMicrophoneUsagePermissionWithAgreeBlock:withDeniedBlock:",
          [NSNumber numberWithInt:ZMPermissionRequestType_Contact]:@"requestContactUsagePermissionWithAgreeBlock:withDeniedBlock:"
          };
    }
    return self;
}


+ (ZMPermissionManager *) sharedInstance
{
    static ZMPermissionManager * singleInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[ZMPermissionManager alloc] init];
    });
    
    return singleInstance;
}




- (BOOL) requestPermissionWithType:(ZMPermissionRequestType) requestType WithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
    NSString * selectorStr = [self.configProperty objectForKey:[NSNumber numberWithInt:requestType]];
    if(!selectorStr)
    {
        NSLog(@"requestPermissionWithType: the method for requestType[%d] not exist",requestType);
    }
    
    SEL selectorObject = NSSelectorFromString(selectorStr);
    
    if([self respondsToSelector:selectorObject])
    {
        /**
         * 获取SEL对应的IMP实现方法调用
         * 1、 适应多个参数的情况
         * 2、 适应返回值为基本数据类型和void的情况；使用performSelector时返回值为基本数据类型可能会闪退
         * 3、 当方法需要频繁调用时，使用函数指针，效率会更高
         **/
        IMP methodIMP = [self methodForSelector:selectorObject];
        BOOL(* funtionPointer)(ZMPermissionManager * ,SEL,void(^)(void),void(^)(void)) = (BOOL(*)(ZMPermissionManager * ,SEL,void(^)(void),void(^)(void)))methodIMP;
        return funtionPointer(self,selectorObject,agreeBlock,deniedBlock);
    }
    else
    {
         NSLog(@"requestPermissionWithType: the method for requestType[%d] not implemented",requestType);
    }

    return NO;
}

#pragma mark - 相册使用权限

- (BOOL) requestPhotoLibraryUsagePermissionWithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
    /**
     * 需要iOS 8.0 以上才支持
     **/
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if(PHAuthorizationStatusDenied == status ||
       PHAuthorizationStatusRestricted == status)
    {
        if(deniedBlock)
        {
            deniedBlock();
        }
        
        return NO;
    }
    else if(PHAuthorizationStatusAuthorized == status)
    {
        if(agreeBlock)
        {
            agreeBlock();
        }
        return YES;
    }
    
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status)
     {
        if(PHAuthorizationStatusAuthorized == status)
        {
            if(agreeBlock)
            {
                // agreeBlock 如果是更新，必须是在主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                   agreeBlock();
                });
            }
        }
         
     }];
    
    
    return NO;
}


#pragma mark - 摄像头使用权限

- (BOOL) requestCameraUsagePermissionWithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
    /**
     * 需要iOS 7.0 才支持
     **/
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if(AVAuthorizationStatusDenied == status ||
       AVAuthorizationStatusRestricted == status)
    {
        if(deniedBlock)
        {
            deniedBlock();
        }
        
        return NO;
    }
    else if(AVAuthorizationStatusAuthorized  == status)
    {
        if(agreeBlock)
        {
            agreeBlock();
        }
        return YES;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
     {
         if(granted && agreeBlock)
         {
             // agreeBlock 如果是更新，必须是在主线程
             dispatch_async(dispatch_get_main_queue(), ^{
                 agreeBlock();
             });
         }
         
     }];
    
    return NO;
}


#pragma mark - 麦克风使用权限

- (BOOL) requestMicrophoneUsagePermissionWithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
    /**
     * 需要iOS 7.0 才支持
     **/
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if(AVAuthorizationStatusDenied == status ||
       AVAuthorizationStatusRestricted == status)
    {
        if(deniedBlock)
        {
            deniedBlock();
        }
        
        return NO;
    }
    else if(AVAuthorizationStatusAuthorized  == status)
    {
        if(agreeBlock)
        {
            agreeBlock();
        }
        return YES;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted)
     {
         if(granted && agreeBlock)
         {
             // agreeBlock 如果是更新，必须是在主线程
             dispatch_async(dispatch_get_main_queue(), ^{
                 agreeBlock();
             });
         }
         
     }];
    
    return NO;
}

#pragma mark - 通讯录使用权限

- (BOOL) requestContactUsagePermissionWithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
// 在iOS9.0 以下使用 <AddressBook/AddressBook.h>
#ifndef __IPHONE_9_0
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if(kABAuthorizationStatusDenied == status ||
        kABAuthorizationStatusRestricted == status)
    {
        if(deniedBlock)
        {
            deniedBlock();
        }
        
        return NO;
    }
    else if(kABAuthorizationStatusAuthorized == status)
    {
        if(agreeBlock)
        {
            agreeBlock();
        }
        return YES;
    }
    
    __block ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    if(addressBook)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(BOOL granted,CFErrorRef error)
                                                 {
                                                    if(granted && agreeBlock)
                                                    {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            agreeBlock();
                                                        });
                                                    }
                                                     if(addressBook)
                                                     {
                                                         CFRelease(addressBook);
                                                         addressBook = NULL;
                                                     }
                                                  
                                                     
                                                 });
        
    }
    
    
#endif
    
    // 在iOS9.0 及以上使用 <Contacts/Contacts.h>
#ifdef __IPHONE_9_0
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if(CNAuthorizationStatusDenied == status ||
       CNAuthorizationStatusRestricted == status)
    {
        if(deniedBlock)
        {
            deniedBlock();
        }
        return NO;
    }
    else if(CNAuthorizationStatusAuthorized == status)
    {
        if(agreeBlock)
        {
            agreeBlock();
        }
        return YES;
    }
    
    CNContactStore * contactStore = [[CNContactStore alloc] init];
    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * error)
     {
         
         if(granted && agreeBlock)
         {
            agreeBlock();
         }
         if(error)
         {
             NSLog(@"requestContactUsagePermission error %@",error.localizedDescription);
         }
         
     }];

#endif

    return NO;
}

#pragma mark - 定位权限
- (BOOL) requestLocationUsagePermissionWithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock
{
    return NO;
}

@end
