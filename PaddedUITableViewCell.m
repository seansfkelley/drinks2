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

    CGFloat heightPadding = 2 * PADDING;
    CGFloat widthPadding = 2 * PADDING;
    CGSize imageSize = self.imageView.image.size;
    if (imageSize.width > imageSize.height) {
        widthPadding += (imageSize.width - imageSize.height);
    }

    CGRect r = self.imageView.frame;
    self.imageView.frame = CGRectMake(
        r.origin.x + PADDING,
        r.origin.y + PADDING,
        r.size.width - widthPadding,
        r.size.height - heightPadding);
}

@end
