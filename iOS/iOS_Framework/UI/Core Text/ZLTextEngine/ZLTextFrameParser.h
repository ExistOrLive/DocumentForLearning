//
//  ZLTextFrameParser.h
//  MOAMessageComponent
//
//  Created by panzhengwei on 2019/3/8.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZLTextViewCoreData;
@class ZLTextEngineModel;
@class ZLTextEngineGlobalConfig;

@interface ZLTextFrameParser : NSObject

+ (ZLTextViewCoreData *) parseTextEngineModel:(NSArray *) engineModels globalAttributes:(ZLTextEngineGlobalConfig *) attributes;

@end
