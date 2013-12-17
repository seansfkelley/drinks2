//
//  PaddedUITableViewCell.m
//  drinks
//
//  Created by Sean Kelley on 12/17/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "PaddedUITableViewCell.h"

@implementation PaddedUITableViewCell

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = self.imageView.frame;
    self.imageView.frame = CGRectMake(r.origin.x + 4, r.origin.y + 4, r.size.width - 8, r.size.height - 8);
}

@end
