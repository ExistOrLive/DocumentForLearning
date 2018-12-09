//
//  ViewController.m
//  TestApp
//
//  Created by panzhengwei on 2018/11/8.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "ViewController.h"
#import "ZMMenuButton.h"

@interface ViewController ()

@property(nonatomic,strong) UITableView * tableView;

@property(nonatomic,strong) NSMutableArray * array;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = [[NSMutableArray alloc] init];
    for(int i= 0;i < 7;i++)
    {
        NSMutableArray * tmpArray =   [NSMutableArray arrayWithArray:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7"]];
        [self.array addObject:tmpArray];
    }
   
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   // [self.tableView registerClass:[UILabel class] forHeaderFooterViewReuseIdentifier:@"dasdasdas"];

    [self.tableView setSectionIndexColor:[UIColor blackColor]];
    
    
    [self.view addSubview:self.tableView];
    
    [self.tableView setEditing:YES animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"0",@"1",@"2",@"3",@"4",@"5"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return [self.array count];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( UITableViewCellEditingStyleDelete == editingStyle)
    {
        [self.array[indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath: [%@]",indexPath);
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection: [%ld]",section);
    return [self.array[section] count];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString * str = self.array[sourceIndexPath.section][sourceIndexPath.row];
    [self.array[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
    
    [self.array[destinationIndexPath.section] insertObject:str atIndex:destinationIndexPath.row];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSLog(@"heightForHeaderInSection:%ld",section);
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
      NSLog(@"viewForHeaderInSection:%ld",section);
//    UILabel * view = (UILabel *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"dasdasdas"];
//
//    if(!view)
//    {
   UILabel * view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
//    }
    
    [view setBackgroundColor:[UIColor whiteColor]];
    [view setText:[NSString stringWithFormat:@"%ld",section]];
    
    return view;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath start: [%@]",indexPath);
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"dasdas"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"dasdas"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        [cell setSeparatorInset:UIEdgeInsetsMake(10, 0, 0, 0)];

        UIView * backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        [backgroundView setBackgroundColor:[UIColor brownColor]];
        [cell setBackgroundView:backgroundView];
        [cell setShowsReorderControl:YES];
  
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"item %@",self.array[indexPath.section][indexPath.row]]];
    [cell.detailTextLabel setText:self.array[indexPath.section][indexPath.row]];
        
    return cell;
    
}


@end
