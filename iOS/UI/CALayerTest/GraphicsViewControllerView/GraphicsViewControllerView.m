//
//  GraphicsViewControllerView.m
//  CALayerTest
//
//  Created by panzhengwei on 2018/12/28.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "GraphicsViewControllerView.h"

@implementation GraphicsViewControllerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIFont * font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:30.0f];
    
    NSString * str = @"Hello World";
    
    [str drawAtPoint:CGPointMake(20, 20) withAttributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor blueColor]}];
    
    [str drawWithRect:CGRectMake(40, 40, 100, 100) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor blueColor]} context:nil];

}


@end
