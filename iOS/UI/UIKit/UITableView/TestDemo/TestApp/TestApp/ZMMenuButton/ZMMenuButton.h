//
//  ZMMenuButton.h
//  iCenter
//
//  Created by panzhengwei on 2018/11/8.
//  Copyright © 2018年 MyApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZMMenuButton : UIButton

@property(nonatomic,assign) NSInteger selectedIndex;


- (void) setupDataSource:(NSArray *) dataSource;

@end
