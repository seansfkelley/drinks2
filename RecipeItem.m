//
//  RecipeItem.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeItem.h"
#import "MeasuredIngredientItem.h"

@interface RecipeItem ()

@property (readwrite) NSString *name;
@property (readwrite) NSArray *measuredIngredients;
@property (readwrite) NSString *instructions;
@property (readwrite) NSString *notes;
@property (readwrite) SourceItem *source;
@property (readwrite) NSString *sourceOverrideUrl;

@end

@implementation RecipeItem

- (id)initWithName:(NSString*)name withMeasuredIngredients:(NSArray*)measuredIngredients withInstructions:(NSString *)instructions withNotes:(NSString *)notes withSource:(SourceItem *)source withSourceOverrideUrl:(NSString *)sourceOverrideUrl{
    self = [super init];
    if (self) {
        self.name = name;
        self.measuredIngredients = measuredIngredients;
        self.instructions = instructions;
        self.notes = notes;
        self.source = source;
        self.sourceOverrideUrl = sourceOverrideUrl;
    }
    return self;
}

- (NSArray *)rawIngredients {
    NSMutableArray *raw = [[NSMutableArray alloc] init];
    for (MeasuredIngredientItem *m in self.measuredIngredients) {
        if (m.ingredient) { // May be false if we have something that has no tag (e.g. "water").
            [raw addObject:m.ingredient];
        }
    }
    return [[NSArray alloc] initWithArray:raw];
}

- (NSString *)normalizedName {
    NSError *error = nil;
    NSRegularExpression *dropCharactersRegex = [[NSRegularExpression alloc] initWithPattern:@"[^\\- a-zA-Z0-9]" options:0 error:&error];
    NSString *normalized = [dropCharactersRegex stringByReplacingMatchesInString:self.name options:0 range:NSMakeRange(0, [self.name length]) withTemplate:@""];
    NSRegularExpression *collapseWhitespaceRegex = [[NSRegularExpression alloc] initWithPattern:@" +" options:0 error:&error];
    normalized = [collapseWhitespaceRegex stringByReplacingMatchesInString:normalized options:0 range:NSMakeRange(0, [normalized length]) withTemplate:@" "];
    return [[normalized lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

@end
