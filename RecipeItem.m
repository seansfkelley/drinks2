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

@end

@implementation RecipeItem

- (id)initWithName:(NSString *)name withMeasuredIngredients:(NSArray *)ingredients withInstructions:(NSString *)instructions withNotes:(NSString *)notes {
    self = [super init];
    self.name = [name copy];
    self.measuredIngredients = [ingredients copy];
    self.instructions = [instructions copy];
    self.notes = [notes copy];
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

@end
