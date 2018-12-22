//
//  DrawRectTestView.m
//  TestApp
//
//  Created by panzhengwei on 2018/12/20.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "DrawRectTestView.h"

@implementation DrawRectTestView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath * path = [[UIBezierPath alloc] init];

    [[UIColor redColor] setStroke];
    [[UIColor blueColor] setFill];

    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0,50)];
    [path addLineToPoint:CGPointMake(50,50)];
    [path addLineToPoint:CGPointMake(0, 0)];

    [path stroke];
    [path fill];
}


@end
