//
//  ViewController.m
//  TestApp
//
//  Created by panzhengwei on 2018/11/8.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "ViewController.h"
#import "UIView+extend.h"
#import "DrawRectTestView.h"

@interface ViewController ()

@property(nonatomic,strong) DrawRectTestView * pview;

//@property(nonatomic,strong) UIButton * button;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pview = [[DrawRectTestView alloc] initWithFrame:CGRectMake(0,0,100,100)];

    [self.pview setBackgroundColor:[UIColor blackColor]];
    
    [self.view addSubview:self.pview];
    
  //  NSLog(@"viewDidLoad %@ %@",self.view,self.pview);
//         self.button  = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 100, 50)];
//
//    [self.button setBackgroundColor:[UIColor redColor]];
//    [self.button setTitle:@"hahaah" forState:UIControlStateNormal];
//    [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//
//    [self.button addTarget:self action:@selector(onclick:) forControlEvents:UIControlEventTouchDown];
//
//    NSLog(@"viewDidLoad %@ %@",self.view,self.button);
//
//    [self.view addSubview:self.button];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}


- (void) onclick:(UIView *) view
{
    NSLog(@"onclick:dasdasda");
    
//    [self.button setBackgroundColor:[UIColor grayColor]];
//    [self.button setTitle:@"dasdasdasdadasdada" forState:UIControlStateNormal];
}


@end
