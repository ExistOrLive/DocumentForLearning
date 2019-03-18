//
//  ZLTextViewCoreData.h
//  ZLGitHubClient
//
//  Created by 朱猛 on 2019/3/5.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface ZLTextViewNestedImageInfo : NSObject

@property(nonatomic,strong) UIImage * image;

@property(nonatomic,assign) CGRect frame;

@end


@interface ZLTextViewNestedRectangleInfo : NSObject

@property(nonatomic,strong) UIColor * fillColor;

@property(nonatomic,strong) UIColor * strokeColor;

@property(nonatomic,assign) CGRect frame;

@end


@interface ZLTextViewCoreData : NSObject

@property(nonatomic,assign,readonly) CGFloat textViewHeight;

@property(nonatomic,assign,readonly) CGFloat textViewWidth;

@property(nonatomic,assign,readonly) CTFrameRef frameRef;

@property(nonatomic,strong) NSArray * imagesArray;

@property(nonatomic,strong) NSArray * rectanglesArray;


- (instancetype) initWithAttributedString:(NSAttributedString *) attributedString
                           textFrameWidth:(CGFloat) width;


- (void) resetAttributedString:(NSAttributedString *) attributedString
                textFrameWidth:(CGFloat) width;

@end
