//
//  ZLTextView.m
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/3/5.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import "ZLTextView.h"
#import "ZLTextViewCoreData.h"

@interface ZLTextView()

@end

@implementation ZLTextView

- (instancetype) init
{
    if(self = [super init])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if(!self.coreData || !self.coreData.frameRef)
    {
        NSLog(@"ZLTextView_drawRect: coredata is nil");
        return;
    }
    
    /**
     *
     * 1、调整坐标系，Core Graphics 坐标系原点在右下角， UIKit 原点在右上角
     **/
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0 , CGRectGetHeight(rect));
    CGContextScaleCTM(contextRef, 1.0 , -1.0);
    
    /**
     *
     * 2.绘制文本
     **/
    CTFrameDraw(self.coreData.frameRef, contextRef);
    
    /**
     *
     * 3、绘制图片
     **/
    for(ZLTextViewNestedImageInfo * imageInfo in self.coreData.imagesArray)
    {
        CGContextDrawImage(contextRef, imageInfo.frame, imageInfo.image.CGImage);
    }
    
    /**
     *
     * 4、绘制矩形
     **/
    for(ZLTextViewNestedRectangleInfo * rectangleInfo in self.coreData.rectanglesArray)
    {
        CGPathRef pathRef = CGPathCreateWithRect(rectangleInfo.frame, nil);
        CGContextSetFillColorWithColor(contextRef,rectangleInfo.fillColor.CGColor);
        CGContextSetStrokeColorWithColor(contextRef,rectangleInfo.strokeColor.CGColor);
        CGContextAddPath(contextRef, pathRef);
        CGPathRelease(pathRef);
        
        CGContextDrawPath(contextRef, kCGPathFillStroke);
    }
    
}



- (void)setCoreData:(ZLTextViewCoreData *)coreData
{
    _coreData = coreData;
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), _coreData.textViewHeight);
    [self setNeedsDisplay];
}


@end
