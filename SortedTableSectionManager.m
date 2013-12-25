//
//  SortedTableSectionManager.m
//  drinks
//
//  Created by Sean Kelley on 12/16/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "SortedTableSectionManager.h"

@interface SortedTableSectionManager ()

@property (readwrite) NSDictionary *nameToSection;
@property (readwrite) NSArray *indexToSection;
@property (readwrite) NSArray *indexToTitle;
@property (readwrite) NSArray *sorted;
@property (readwrite) NSArray *sectionIndexTitles;

@end

@implementation SortedTableSectionManager

NSString *ALPHABET_UPPER = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z #";

- (id)initWithArray:(NSArray *)array sortedByProperty:(NSString *)property {
    self = [super init];
    if (self) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:property ascending:YES selector:@selector(caseInsensitiveCompare:)];
        self.sorted = [array sortedArrayUsingDescriptors:@[descriptor]];
        
        NSMutableDictionary *nameToSection = [[NSMutableDictionary alloc] init];
        NSMutableArray *indexToSection = [[NSMutableArray alloc] init];
        NSMutableArray *indexToTitle = [[NSMutableArray alloc] init];
        
        for (NSObject *o in self.sorted) {
            NSString *key = [o performSelector:NSSelectorFromString(property)];
            key = [key uppercaseString];
            NSString *first = [NSString stringWithFormat:@"%C", [key characterAtIndex:0]];
            if (![nameToSection objectForKey:first]) {
                // Because this is sorted, we know we can stick the new array onto the end of indexToSection
                // and we'll be correct.
                NSMutableArray *section = [[NSMutableArray alloc] init];
                [nameToSection setObject:section forKey:first];
                [indexToSection addObject:section];
                [indexToTitle addObject:first];
            }
            [[nameToSection objectForKey:first] addObject:o];
        }
        
        self.nameToSection = nameToSection;
        self.indexToSection = indexToSection;
        self.indexToTitle = indexToTitle;
        self.sectionIndexTitles = [ALPHABET_UPPER componentsSeparatedByString:@" "];
    }
    return self;
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [[self.indexToSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSUInteger)sortedIndexForIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = 0;
    for (int i = 0; i < indexPath.section; ++i) {
        index += [[self.indexToSection objectAtIndex:i] count];
    }
    return index + indexPath.row;
}

- (NSUInteger)sectionForSectionIndexTitle:(NSString *)title {
    for (int i = (int) [self.indexToTitle count] - 1; i >= 0 ; --i) {
        NSComparisonResult result = [title compare:[self.indexToTitle objectAtIndex:i]];
        if (result == NSOrderedDescending || result == NSOrderedSame) {
            return i;
        }
    }
    return [self.indexToTitle count] - 1;
}

@end
