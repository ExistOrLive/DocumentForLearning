//
//  UIView+extend.m
//  TestApp
//
//  Created by panzhengwei on 2018/12/20.
//  Copyright © 2018年 ZTE. All rights reserved.
//

#import "UIView+extend.h"
#import <objc/runtime.h>

@implementation UIView(extend)

+ (void) load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
     
        
        Method sourceMethod1 = class_getInstanceMethod([self class], @selector(setNeedsDisplay));
        Method dstMethod1 = class_getInstanceMethod([self class], @selector(setNewNeedsDisplay));
        
        Method sourceMethod2 = class_getInstanceMethod([self class], @selector(setNeedsLayout));
        Method dstMethod2 = class_getInstanceMethod([self class], @selector(setNewNeedsLayout));
        
        Method sourceMethod6 = class_getInstanceMethod([self class], @selector(displayLayer:));
        Method dstMethod6 = class_getInstanceMethod([self class], @selector(newDisplayLayer:));
        
        Method sourceMethod = class_getInstanceMethod([self class], @selector(drawLayer:inContext:));
        Method dstMethod = class_getInstanceMethod([self class], @selector(newDrawLayer:inContext:));
        
        Method sourceMethod3 = class_getInstanceMethod([self class], @selector(layerWillDraw:));
        Method dstMethod3 = class_getInstanceMethod([self class], @selector(newLayerWillDraw:));
        
        Method sourceMethod4 = class_getInstanceMethod([self class], @selector(layoutSublayersOfLayer:));
        Method dstMethod4 = class_getInstanceMethod([self class], @selector(newLayoutSublayersOfLayer:));
        
        Method sourceMethod5 = class_getInstanceMethod([self class], @selector(actionForLayer:forKey:));
        Method dstMethod5 = class_getInstanceMethod([self class], @selector(newActionForLayer:forKey:));
        

        
        method_exchangeImplementations(sourceMethod,dstMethod);
        method_exchangeImplementations(sourceMethod1,dstMethod1);
        method_exchangeImplementations(sourceMethod2,dstMethod2);
        method_exchangeImplementations(sourceMethod3,dstMethod3);
        method_exchangeImplementations(sourceMethod4,dstMethod4);
        method_exchangeImplementations(sourceMethod5,dstMethod5);
         method_exchangeImplementations(sourceMethod6,dstMethod6);
    
    });
    
}

- (void) setNewNeedsLayout
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
    NSLog(@"setNeedsLayout; start %@",self);
    }
    
    [self setNewNeedsLayout];
    
   // NSLog(@"setNeedsLayout: end %@",self);
}

- (void) setNewNeedsDisplay
{
    
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
    NSLog(@"setNeedsDisplay; start %@",self);
    }
    
    [self setNewNeedsDisplay];
    
    //NSLog(@"setNeedsDisplay: end %@",self);
}



#pragma mark - CALayerDelegate

/* If defined, called by the default implementation of the -display
 * method, in which case it should implement the entire display
 * process (typically by setting the `contents' property). */

- (void)newDisplayLayer:(CALayer *)layer
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
    NSLog(@"displayer: start ...%@",self);
    }
    
    [self newDisplayLayer:layer];
    
    //NSLog(@"displayer: end ...%@",self);
}

/* If defined, called by the default implementation of -drawInContext: */

- (void)newDrawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
    NSLog(@"drawLayer:inContext: start ...%@",self);
    }
    
    [self newDrawLayer:layer inContext:ctx];
    
    //NSLog(@"drawLayer:inContext: end ...%@",self);
}



/* If defined, called by the default implementation of the -display method.
 * Allows the delegate to configure any layer state affecting contents prior
 * to -drawLayer:InContext: such as `contentsFormat' and `opaque'. It will not
 * be called if the delegate implements -displayLayer. */

- (void)newLayerWillDraw:(CALayer *)layer
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
        NSLog(@"layerWillDraw: start ...%@",self);
    }
    
    [self newLayerWillDraw:layer];
    
    //NSLog(@"layerWillDraw: end ...%@",self);
}

/* Called by the default -layoutSublayers implementation before the layout
 * manager is checked. Note that if the delegate method is invoked, the
 * layout manager will be ignored. */

- (void)newLayoutSublayersOfLayer:(CALayer *)layer
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
        NSLog(@"layoutSublayersOfLayer: start ...%@",self);
    }
    
    [self newLayoutSublayersOfLayer:layer];
    
    // NSLog(@"layoutSublayersOfLayer: end ...%@",self);
}

/* If defined, called by the default implementation of the
 * -actionForKey: method. Should return an object implementating the
 * CAAction protocol. May return 'nil' if the delegate doesn't specify
 * a behavior for the current event. Returning the null object (i.e.
 * '[NSNull null]') explicitly forces no further search. (I.e. the
 * +defaultActionForKey: method will not be called.) */

- (nullable id<CAAction>)newActionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if([self isKindOfClass:NSClassFromString(@"DrawRectTestView")])
    {
         NSLog(@"actionForLayer:forKey: start ...%@  event:%@",self,event);
    }
    
   id a =  [self newActionForLayer:layer forKey:event];
    
    //NSLog(@"actionForLayer:forKey: end ...%@",self);
    
    return a;
}



@end
