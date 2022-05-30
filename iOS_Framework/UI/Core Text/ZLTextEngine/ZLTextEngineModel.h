//
//  ZLTextEngineModel.h
//  MOAMessageComponent
//
//  Created by panzhengwei on 2019/3/8.
//  Copyright © 2019年 ZTE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZLTextEngineAttributedStringModel: NSObject

@property(nonatomic,strong) NSString * content;

@property(nonatomic,strong) UIFont * font;

@property(nonatomic,strong) UIColor * foregroundColor;

@property(nonatomic,strong) NSDictionary * otherAttributes;

@end


@interface ZLTextEngineImageModel: NSObject

@property(nonatomic,strong) UIImage * image;

@property(nonatomic,assign) CGSize size;

@end


@interface ZLTextEngineRectangleModel: NSObject

@property(nonatomic,strong) UIColor * fillColor;

@property(nonatomic,strong) UIColor * strokeColor;

@property(nonatomic,assign) CGSize size;

@end


@interface ZLTextEngineGlobalConfig : NSObject

@property(nonatomic,assign) CGFloat width;

@property(nonatomic,strong) NSDictionary * globalAttributes;

@end

