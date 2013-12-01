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

@end

@implementation RecipeItem

- (id)initWithName:(NSString *)name withMeasuredIngredients:(NSArray *)ingredients withInstructions:(NSString *)instructions {
    self = [super init];
    self.name = [name copy];
    self.measuredIngredients = [ingredients copy];
    self.instructions = [instructions copy];
    return self;
}

@end
