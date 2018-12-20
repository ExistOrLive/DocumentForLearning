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
    
    //[self.tableView setEditing:YES animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView");
    return [self.array count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection: [%ld]",section);
    return [self.array[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellForRowAtIndexPath start: [%@]",indexPath);
  //  UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"dasdas"];
    UITableViewCell * cell = nil;
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"dasdas"];
        [cell setAccessoryType:UITableViewCellAccessoryDetailButton];
        [cell setSeparatorInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        UIView * backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        [backgroundView setBackgroundColor:[UIColor brownColor]];
        [cell setBackgroundView:backgroundView];
        [cell setShowsReorderControl:NO];
        
    }
    
    [cell.textLabel setText:[NSString stringWithFormat:@"item %@",self.array[indexPath.section][indexPath.row]]];
    [cell.detailTextLabel setText:self.array[indexPath.section][indexPath.row]];
    
    return cell;
    
}




#pragma mark - 索引栏 section index bar

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"1",@"2",@"3",@"4",@"5",@"6"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
{
    return index;
}


#pragma mark - 编辑模式

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


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSString * str = self.array[sourceIndexPath.section][sourceIndexPath.row];
    [self.array[sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];

    [self.array[destinationIndexPath.section] insertObject:str atIndex:destinationIndexPath.row];

}




#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSLog(@"heightForHeaderInSection:%ld",section);
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath: [%@]",indexPath);
    return 50 + indexPath.section * 10;
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id a = self.array[indexPath.section][indexPath.row];
//    id b = self.array[indexPath.section][indexPath.row+1];
//
//    self.array[indexPath.section][indexPath.row] = b;
//    self.array[indexPath.section][indexPath.row+1] = a;
//
//
//    [tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]];
    
//    NSLog(@"insert data");
//
//    [self.array[6] insertObject:@"insertData" atIndex:indexPath.row];
//
//    [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:6]] withRowAnimation:UITableViewRowAnimationNone];
    
    NSLog(@"reload data");
    
    [tableView reloadData];
}



@end
