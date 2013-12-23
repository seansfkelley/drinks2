//
//  LongFormTextTableViewCell.m
//  drinks
//
//  Created by Sean Kelley on 12/23/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "LongFormTextTableViewCell.h"

@implementation LongFormTextTableViewCell

- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"%@", self.textView.text); // In the future, this should resize it.
}

@end
