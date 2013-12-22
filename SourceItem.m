//
//  SourceItem.m
//  drinks
//
//  Created by Sean Kelley on 12/21/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "SourceItem.h"

@interface SourceItem ()

@property (readwrite) NSString *name;
@property (readwrite) NSString *url;

@end

@implementation SourceItem

- (id)initWithName:(NSString *)name withUrl:(NSString *)url {
    self = [super init];
    if (self) {
        self.name = name;
        self.url = url;
    }
    return self;
}


@end
