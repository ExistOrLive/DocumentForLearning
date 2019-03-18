//
//  ZLTextFrameParser.m
//  MOAMessageComponent
//
//  Created by panzhengwei on 2019/3/8.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import "ZLTextFrameParser.h"
#import "ZLTextEngineModel.h"
#import "ZLTextViewCoreData.h"
#import "NSAttributedString+ZLTextEngine.h"

@implementation ZLTextFrameParser

+ (ZLTextViewCoreData *) parseTextEngineModel:(NSArray *) engineModels globalAttributes:(ZLTextEngineGlobalConfig *) config
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] init];
    
    for(id model in engineModels)
    {
        if([model isMemberOfClass:[ZLTextEngineAttributedStringModel class]])
        {
            NSAttributedString * tmpString = [self getAttributedStringFromAttributedStringModel:model];
            [attributedString appendAttributedString:tmpString];
        }
        
        if([model isMemberOfClass:[ZLTextEngineImageModel class]])
        {
            NSAttributedString * tmpString = [self getAttributedStringFromImageModel:model];
            [attributedString appendAttributedString:tmpString];
        }
        
        if([model isMemberOfClass:[ZLTextEngineRectangleModel class]])
        {
            NSAttributedString * tmpString = [self getAttributedStringFromRectangleModel:model];
            [attributedString appendAttributedString:tmpString];
        }
    }
    
    if(config.globalAttributes)
    {
        [attributedString addAttributes:config.globalAttributes range:NSMakeRange(0, [attributedString length])];
    }
    
    ZLTextViewCoreData * coreData = [[ZLTextViewCoreData alloc] initWithAttributedString:attributedString textFrameWidth:config.width];
    
    return coreData;
}

#pragma mark - 解析 ZLTextEngineAttributedStringModel

+ (NSAttributedString *) getAttributedStringFromAttributedStringModel:(ZLTextEngineAttributedStringModel *)model
{
    return [NSMutableAttributedString attributedStringWithText:model.content font:model.font textForegroundColor:model.foregroundColor paragraphStyle:nil otherAttributes:model.otherAttributes];
}

#pragma mark - 解析 ZLTextEngineImageModel

+ (NSAttributedString *) getAttributedStringFromImageModel:(ZLTextEngineImageModel *)model
{
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:@"image"];
    
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)attributeString, CFRangeMake(0, [attributeString length]), kCTForegroundColorAttributeName, [UIColor clearColor].CGColor);

    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.dealloc = &runDelegateDeallocateCallback;
    callBacks.getAscent = &runDelegateGetAscentCallback;
    callBacks.getDescent = &runDelegateGetDescentCallback;
    callBacks.getWidth = &runDelegateGetWidthCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *)(model));
    
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)attributeString, CFRangeMake(0, [attributeString length]), kCTRunDelegateAttributeName, delegate);
    
    CFRelease(delegate);
    
    return attributeString;
}


#pragma mark - 解析 ZLTextEngineRectangleModel

+ (NSAttributedString *) getAttributedStringFromRectangleModel:(ZLTextEngineRectangleModel *)model
{
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:@"rectangle"];
    
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)attributeString, CFRangeMake(0, [attributeString length]), kCTForegroundColorAttributeName, [UIColor clearColor].CGColor);
    
    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    callBacks.version = kCTRunDelegateVersion1;
    callBacks.dealloc = &runDelegateDeallocateCallback;
    callBacks.getAscent = &runDelegateGetAscentCallback;
    callBacks.getDescent = &runDelegateGetDescentCallback;
    callBacks.getWidth = &runDelegateGetWidthCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callBacks, (__bridge void *)(model));
    
    CFAttributedStringSetAttribute((__bridge CFMutableAttributedStringRef)attributeString, CFRangeMake(0, [attributeString length]), kCTRunDelegateAttributeName, delegate);
    
    CFRelease(delegate);
    
    return attributeString;
}

#pragma mark - kCTRunDelegateAttributeName

void runDelegateDeallocateCallback (void * refCon)
{
    
}

CGFloat runDelegateGetAscentCallback(void * refCon)
{
    id model = (__bridge id)refCon;
    if([model isKindOfClass:[ZLTextEngineImageModel class]])
    {
        ZLTextEngineImageModel * imageModel =  (ZLTextEngineImageModel *)model;
        return imageModel.size.height / 2;
    }
    else if([model isKindOfClass:[ZLTextEngineRectangleModel class]])
    {
        ZLTextEngineRectangleModel * rectangleModel = (ZLTextEngineRectangleModel *)model;
        return rectangleModel.size.height / 2;
    }
    return 0;
}
CGFloat runDelegateGetDescentCallback(void * refCon)
{
    id model = (__bridge id)refCon;
    if([model isKindOfClass:[ZLTextEngineImageModel class]])
    {
        ZLTextEngineImageModel * imageModel =  (ZLTextEngineImageModel *)model;
        return imageModel.size.height / 2;
    }
    else if([model isKindOfClass:[ZLTextEngineRectangleModel class]])
    {
        ZLTextEngineRectangleModel * rectangleModel = (ZLTextEngineRectangleModel *)model;
        return rectangleModel.size.height / 2;
    }
    return 0;
}

CGFloat runDelegateGetWidthCallback(void * refCon)
{
    id model = (__bridge id)refCon;
    if([model isKindOfClass:[ZLTextEngineImageModel class]])
    {
        ZLTextEngineImageModel * imageModel =  (ZLTextEngineImageModel *)model;
        return imageModel.size.width;
    }
    else if([model isKindOfClass:[ZLTextEngineRectangleModel class]])
    {
        ZLTextEngineRectangleModel * rectangleModel = (ZLTextEngineRectangleModel *)model;
        return rectangleModel.size.width;
    }
    return 0;
}


@end
