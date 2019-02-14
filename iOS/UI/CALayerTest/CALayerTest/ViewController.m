//
//  ViewController.m
//  CALayerTest
//
//  Created by panzhengwei on 2018/12/28.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "ViewController.h"
#import "GraphicsViewControllerView.h"

@interface ViewController ()

@property(nonatomic,strong) UIView * layerView;

@property(nonatomic,strong)GraphicsViewControllerView * graphicsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    self.layerView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.layerView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.layerView];
    
    CALayer * blueLayer = [[CALayer alloc] init];
    blueLayer.frame = CGRectMake(50.0, 50.0, 100.0, 100.0);
    blueLayer.backgroundColor = [[UIColor blueColor] CGColor];
    
    [self.layerView.layer addSublayer:blueLayer];
    
//    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc] init];
//    [gestureRecognizer addTarget:self action:@selector(onClick)];
//
//    [self.layerView addGestureRecognizer:gestureRecognizer];
    

    
    
    self.graphicsView = [[GraphicsViewControllerView alloc] initWithFrame:CGRectMake(100, 300, 300, 400)];
    UIPanGestureRecognizer * panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
    [panGestureRecognizer addTarget:self action:@selector(onPan:)];
    
    [self.graphicsView addGestureRecognizer:panGestureRecognizer];
    [self.view addSubview:self.graphicsView];
    
    
}

- (void) onClick
{
    CATransform3D rotationMatrix = CATransform3DMakeRotation(M_PI / 4, 0, 1, 0);
    
    self.graphicsView.layer.transform = rotationMatrix;
}

- (void) onPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:recognizer.view];
    
    NSLog(@"state[%d] point.x[%f] point.y[%f] frame.x[%f] frame.y[%f]",recognizer.state,point.x,point.y,CGRectGetMinX(recognizer.view.frame),CGRectGetMinY(recognizer.view.frame));
    
    if(recognizer.state != UIGestureRecognizerStateBegan)
    {
         self.graphicsView.layer.transform = CATransform3DMakeTranslation(point.x, point.y, 0);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
