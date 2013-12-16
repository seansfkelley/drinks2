//
//  SortedTableSectionManager.m
//  drinks
//
//  Created by Sean Kelley on 12/16/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "SortedTableSectionManager.h"

@interface SortedTableSectionManager ()

@property NSMutableDictionary *groupedByFirstLetter;
@property (readwrite) NSArray *sorted;

@end

@implementation SortedTableSectionManager

- (id)initWithArray:(NSArray *)array sortedByProperty:(NSString *)property {
    self = [super init];
    if (self) {
        // Why is this out of order?? All the strings start with ASCII and are capitalized...
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:property ascending:YES];
        self.sorted = [array sortedArrayUsingDescriptors:@[descriptor]];
        self.groupedByFirstLetter = [[NSMutableDictionary alloc] init];
        for (NSObject *o in self.sorted) {
            NSString *key = [o performSelector:NSSelectorFromString(property)];
            NSString *first = [NSString stringWithFormat:@"%C", [key characterAtIndex:0]];
            if (![self.groupedByFirstLetter objectForKey:first]) {
                [self.groupedByFirstLetter setObject:[[NSMutableArray alloc] init] forKey:first];
            }
            [[self.groupedByFirstLetter objectForKey:first] addObject:o];
        }
    }
    return self;
}

@end
