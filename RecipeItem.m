//
//  RecipeItem.m
//  drinks
//
//  Created by Sean Kelley on 11/29/13.
//  Copyright (c) 2013 Sean Kelley. All rights reserved.
//

#import "RecipeItem.h"

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

@end
