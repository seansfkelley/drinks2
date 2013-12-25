//
//  UIUtils.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (CGFloat)DEFAULT_CELL_HEIGHT { return 44; }
+ (CGFloat)DEFAULT_CELL_WIDTH { return 320 - 40; /* iPhone width - inferred padding. */ }
+ (UIFont *)DEFAULT_CELL_FONT { return [UIFont systemFontOfSize:14.0f]; }

+ (CGFloat)cellHeightForText:(NSString *)text {
    return [UIUtils cellHeightForText:text withWidth:UIUtils.DEFAULT_CELL_WIDTH];
}

+ (CGFloat)cellHeightForText:(NSString *)text withWidth:(CGFloat)width {
    return [text boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:UIUtils.DEFAULT_CELL_FONT} context:nil].size.height + UIUtils.DEFAULT_CELL_HEIGHT - UIUtils.DEFAULT_CELL_FONT.lineHeight;
}

+ (id)nearestSuperview:(UIView *)view ofType:(Class)class {
    UIView *superview = view.superview;
    while (superview && ![superview isKindOfClass:class]) {
        superview = superview.superview;
    }
    return superview;
}

@end
