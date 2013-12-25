//
//  UIUtils.h
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtils : NSObject

+ (CGFloat)DEFAULT_CELL_HEIGHT;
+ (CGFloat)DEFAULT_CELL_WIDTH;
+ (UIFont *)DEFAULT_CELL_FONT;
+ (CGFloat)cellHeightForText:(NSString *)text;
+ (CGFloat)cellHeightForText:(NSString *)text withWidth:(CGFloat)width;

+ (id)nearestSuperview:(UIView *)view ofType:(Class)class;

@end
