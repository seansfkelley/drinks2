//
//  UIUtils.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (id)nearestSuperview:(UIView *)view ofType:(Class)class {
    UIView *superview = view.superview;
    while (superview && ![superview isKindOfClass:class]) {
        superview = superview.superview;
    }
    return superview;
}

@end
