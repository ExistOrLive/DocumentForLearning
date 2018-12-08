//
//  ZMMenuButton.m
//  iCenter
//
//  Created by panzhengwei on 2018/11/8.
//  Copyright © 2018年 MyApp. All rights reserved.
//

#import "ZMMenuButton.h"

#define ZMMenuButtonlabelStyle @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor blackColor]}

#define ZMMenuCellHeight 40


@interface ZMMenuButton() <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) UITableView * menuTableView;

@end


@implementation ZMMenuButton

- (void) setupDataSource:(NSArray *) dataSource
{
    if(!dataSource)
    {
        return;
    }
    
    self.dataSource = dataSource;
    
    [self setBackgroundColor:[UIColor lightGrayColor]];
    
    NSAttributedString * contentStr = [[NSAttributedString alloc] initWithString:[self.dataSource objectAtIndex:self.selectedIndex] attributes:ZMMenuButtonlabelStyle];
    [self setAttributedTitle:contentStr forState:UIControlStateNormal];
    
     __weak typeof (self) wSelf = self;
    [self addTarget:wSelf action:@selector(onButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupMenuTablView];
    
}

- (void) setupMenuTablView
{
    CGFloat menuTableViewHeight = ZMMenuCellHeight * self.dataSource.count;
    self.menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 - menuTableViewHeight, self.frame.size.width, menuTableViewHeight)];
    
    [self.menuTableView setHidden:YES];
    [self.menuTableView setDelegate:self];
    [self.menuTableView setDataSource:self];
    [self.menuTableView setScrollEnabled:NO];
    
    self.menuTableView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.menuTableView.layer.borderWidth = 2;
    self.menuTableView.layer.cornerRadius = 2;
    [self addSubview:self.menuTableView];
    
}


- (void) onButtonSelected:(UIButton *) button
{
    if([self.menuTableView isHidden])
    {
        [self.menuTableView setHidden:NO];
        [self setUserInteractionEnabled:YES];
    }
    else
    {
        [self.menuTableView setHidden:YES];
    }
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ZMMenuCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    NSAttributedString * contentStr = [[NSAttributedString alloc] initWithString:[self.dataSource objectAtIndex:self.selectedIndex] attributes:ZMMenuButtonlabelStyle];
    [self setAttributedTitle:contentStr forState:UIControlStateNormal];
    [self.menuTableView setHidden:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    UILabel * textView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0 , self.frame.size.width, ZMMenuCellHeight)];
    textView.text = [self.dataSource objectAtIndex:indexPath.row];
    [textView setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:textView];
    
    return cell;
    
}


/**
 *  menuTableView 不在ZMMenuButton的bounds范围内，不能够响应点击事件
 *  通过重写hitTest:withTest: 方法能够检查 menuTableView 是否需要响应事件
 *  前提是事件传递到ZMMenuButton
 *  hitTest:withTest:  默认只会检查bounds是否包含point，并返回响应的视图
 **/

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView * view = [super hitTest:point withEvent:event];
    
    if(!view)
    {
        CGPoint mypoint = [self.menuTableView convertPoint:point fromView:self];
        
        if(CGRectContainsPoint(self.menuTableView.bounds, mypoint))
        {
            return self.menuTableView;
        }
        
    }
    
    return view;
}





@end
