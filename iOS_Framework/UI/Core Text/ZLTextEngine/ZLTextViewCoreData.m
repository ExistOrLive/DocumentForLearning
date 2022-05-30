//
//  ZLTextViewCoreData.m
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/3/5.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import "ZLTextViewCoreData.h"
#import "ZLTextEngineModel.h"

@implementation ZLTextViewNestedImageInfo

@end

@implementation ZLTextViewNestedRectangleInfo

@end



@implementation ZLTextViewCoreData

- (instancetype) initWithAttributedString:(NSAttributedString *) attributedString
                           textFrameWidth:(CGFloat) width
{
    if(self = [super init])
    {
        [self parseAttribuedString:attributedString
                    textFrameWidth:width];
    }
    
    return self;
}


- (void) resetAttributedString:(NSAttributedString *) attributedString
                textFrameWidth:(CGFloat) width
{
    [self parseAttribuedString:attributedString
                textFrameWidth:width];
}


/**
 *
 * 计算高度，生成CTFrame
 **/
- (void) parseAttribuedString:(NSAttributedString *) attributedString
               textFrameWidth:(CGFloat) width
{
    
    /**
     *
     * 1、 创建CTFrame 估算高度
     **/
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    CGSize suggestSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, 0), NULL, CGSizeMake(width, CGFLOAT_MAX), nil);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, CGRectMake(0, 0, width,suggestSize.height));
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, [attributedString length]), pathRef, NULL);
    
    CGPathRelease(pathRef);
    CFRelease(framesetterRef);
    
    if(_frameRef && _frameRef != frameRef)
    {
        CFRelease(_frameRef);
    }
    _frameRef = frameRef;
    _textViewHeight = suggestSize.height;
    _textViewWidth = width;
    
    /**
     *
     * 2。处理图片和矩形
     **/
    NSMutableArray * imageInfoArray = [[NSMutableArray alloc] init];
    NSMutableArray * rectangleInfoArray = [[NSMutableArray alloc] init];
    
    CFArrayRef linesArray = CTFrameGetLines(frameRef);
    NSUInteger linesCount = CFArrayGetCount(linesArray);
    
    CGPoint lineOrigins[linesCount];
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), lineOrigins);
    
    for(int i = 0 ; i < linesCount; i++)
    {
        CTLineRef lineRef = CFArrayGetValueAtIndex(linesArray, i);
        CFArrayRef runsArray = CTLineGetGlyphRuns(lineRef);
        NSUInteger runsCount = CFArrayGetCount(runsArray);
        
        for(int j = 0; j < runsCount; j++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runsArray, j);
            CFDictionaryRef attribuetsDic = CTRunGetAttributes(run);
            
            CTRunDelegateRef runDelegate = CFDictionaryGetValue(attribuetsDic, kCTRunDelegateAttributeName);
            
            if(!runDelegate)
            {
                continue;
            }
            
            void * refCon = CTRunDelegateGetRefCon(runDelegate);
            id tmpCon = (__bridge id)refCon;
            
            if([tmpCon isKindOfClass:[ZLTextEngineImageModel class]] || [tmpCon isKindOfClass:[ZLTextEngineRectangleModel class]])
            {
                /**
                 *
                 * 计算矩形或者图片在TextView中的frame
                 **/
                CGRect runBounds;
                
                CGFloat acsent;
                CGFloat desent;
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &acsent, &desent, NULL);
                
                CGFloat xOffset = CTLineGetOffsetForStringIndex(lineRef, CTRunGetStringRange(run).location, nil);
                
                CGPoint lineOrigin = lineOrigins[i];
                
                runBounds.origin.x = lineOrigin.x + xOffset;
                runBounds.origin.y = lineOrigin.y - desent;
                runBounds.size.height = acsent + desent;
                runBounds.size.width = width;
                
                CGPathRef pathRef = CTFrameGetPath(frameRef);
                CGRect colRect = CGPathGetBoundingBox(pathRef);
                
                CGRect runFrame = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
                
                if([tmpCon isKindOfClass:[ZLTextEngineImageModel class]])
                {
                    ZLTextViewNestedImageInfo * imageInfo = [[ZLTextViewNestedImageInfo alloc] init];
                    imageInfo.frame = runFrame;
                    imageInfo.image = ((ZLTextEngineImageModel *) tmpCon).image;
                    [imageInfoArray addObject:imageInfo];
                }
                else if([tmpCon isKindOfClass:[ZLTextEngineRectangleModel class]])
                {
                    ZLTextViewNestedRectangleInfo * rectangleInfo = [[ZLTextViewNestedRectangleInfo alloc] init];
                    rectangleInfo.frame = runFrame;
                    rectangleInfo.strokeColor = ((ZLTextEngineRectangleModel *) tmpCon).strokeColor;
                    rectangleInfo.fillColor = ((ZLTextEngineRectangleModel *) tmpCon).fillColor;
                    [rectangleInfoArray addObject:rectangleInfo];
                }
            }
        }
    }
    
    if([imageInfoArray count] > 0)
    {
        self.imagesArray = [imageInfoArray copy];
    }
    if([rectangleInfoArray count] > 0)
    {
        self.rectanglesArray = [rectangleInfoArray copy];
    }
    
}

- (void) dealloc
{
    CFRelease(self.frameRef);
}


@end
