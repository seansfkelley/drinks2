//
//  PaddedUITableViewCell.m
//  drinks
//
//  Created by Sean Kelley on 12/17/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "PaddedUITableViewCell.h"

#define PADDING 4

@implementation PaddedUITableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.imageView.frame;
    self.imageView.frame = CGRectMake(
        r.origin.x + PADDING,
        r.origin.y + PADDING,
        r.size.width  - 2 * PADDING,
        r.size.height - 2 * PADDING);
}

@end
