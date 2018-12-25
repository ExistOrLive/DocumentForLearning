//
//  ZMPermissionManager.h
//  iCenter
//
//  Created by zhumeng on 2018/10/23.
//  Copyright © 2018年 MyApp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    ZMPermissionRequestType_PhotoLibrary,          // 相册权限
    ZMPermissionRequestType_Camera,                // 摄像头权限
    ZMPermissionRequestType_Microphone,            // 麦克风权限
    ZMPermissionRequestType_Contact,               // 通讯录权限
    ZMPermissionRequestType_Location               // 定位权限
}ZMPermissionRequestType;


/**
 * 最低支持iOS 8.0
 **/
@interface ZMPermissionManager : NSObject

/**
 *  创建单例
 **/
+ (ZMPermissionManager *) sharedInstance;


/**
 *  申请相应的权限
 *  @param requestType  申请的权限类型
 *  @param agreeBlock   申请成功回调
 *  @param deniedBlock  拒绝申请的回调
 **/

- (BOOL) requestPermissionWithType:(ZMPermissionRequestType) requestType WithAgreeBlock:(void(^)(void)) agreeBlock withDeniedBlock:(void(^)(void)) deniedBlock;


@end
